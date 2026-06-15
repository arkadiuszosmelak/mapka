# Założenia projektowe i architektoniczne (Flutter)

Uniwersalny zestaw decyzji projektowych do wykorzystania jako punkt startowy dla nowych
aplikacji Flutter. Dokument celowo **pomija specyfikę konkretnego projektu** (baza danych,
backend, dostawca auth, tokeny, sekrety) i skupia się na strukturze, architekturze, tooling
i stacku, które sprawdzają się w różnych typach aplikacji.

---

## 1. Filozofia i zasady

- **Clean Architecture** w wariancie pragmatycznym — warstwy `data` / `domain` / `presentation`,
  zależności skierowane do środka (presentation → domain ← data), bez nadmiernej ceremonii.
- **KISS** — najprostsze rozwiązanie spełniające wymaganie; bez abstrakcji „na zapas”.
- **DRY** — wspólną logikę wydzielamy, gdy ten sam wzorzec pojawia się 3+ razy (nie wcześniej).
- **YAGNI** — nie dodajemy kodu „na wszelki wypadek”; martwy kod usuwamy.
- **SOLID** — w szczególności Single Responsibility i Dependency Inversion (interfejs w `domain`,
  implementacja w `data`, wstrzykiwana przez DI).
- Unikamy metod statycznych — preferujemy dependency injection (wyjątek: czyste formattery/utils).

---

## 2. Monorepo modularne (Melos)

Projekt to **monorepo zarządzane przez [Melos](https://melos.invertase.dev/)**. Każdy moduł to
osobny pakiet Dart/Flutter w `modules/**`, z własnym `pubspec.yaml`, `lib/`, `test/`.

### Typy modułów i reguły zależności

| Typ           | Prefiks | Może importować                |
| ------------- | ------- | ------------------------------ |
| App           | —       | wszystkie moduły               |
| Core          | —       | nic                            |
| Design System | —       | tylko `core`                   |
| Feature       | `f_`    | `d_*`, `core`, `design_system` |
| Data          | `d_`    | `core`, inne `d_*` (ostrożnie) |

Reguły, które utrzymują architekturę „czystą”:

- **Moduły feature (`f_`) nie importują innych modułów feature.** Komunikacja między feature'ami
  idzie przez warstwę app (routing/callbacki) albo przez wspólny moduł `d_`.
- **Każdy moduł importuje `core`.**
- `core` nie zależy od niczego (poza paczkami zewnętrznymi) — to fundament współdzielony.
- `design_system` zależy tylko od `core`.
- Granice zależności warto **wymuszać automatycznie** (lint/skrypt sprawdzający `pubspec.yaml`)
  i wizualizować jako graf modułów (patrz sekcja Tooling).

### Po co modularność

- Wymuszone granice = mniejsze sprzężenie, łatwiejsze testy i refactor.
- Szybsze buildy i analiza per-pakiet.
- Czytelny podział własności (kto odpowiada za co).
- Łatwe wycinanie/przenoszenie feature'ów między projektami.

### Szablon modułu

Trzymamy `modules/module_template` jako wzorzec + skrypt generujący nowy moduł (kopiuje template,
podmienia nazwy, dopina do app). Każdy moduł eksponuje **barrel/manifest** (`<module>_module.dart`)
opisujący to, co moduł wnosi do aplikacji:

```dart
class FeatureModule extends ModuleManifest {
  const FeatureModule();

  @override
  MicroPackageModule get dependencyInjectionModule => FeaturePackageModule(); // DI
  @override
  List<RouteGuard> get routeGuards => [...];           // guardy routingu
  @override
  List<NavigatorObserver> get routeObservers => [...]; // obserwatory nawigacji
}
```

App zbiera te manifesty w jedną listę i z nich składa: rejestrację DI, router i observery.

### Struktura katalogów w module

```
lib/
├── dependency_injection/    # rejestracja Injectable (@module / *.module.dart)
├── domain/
│   ├── model/               # modele domenowe
│   └── service/             # interfejsy (abstrakcje)
├── data/
│   ├── data_source/         # Retrofit @RestApi
│   ├── model/               # DTO (@JsonSerializable)
│   ├── mapper/              # extension DtoMapper -> domain
│   └── service/             # implementacje interfejsów z domain/service
├── presentation/
│   ├── page/<page_name>/
│   │   ├── <page_name>_page.dart
│   │   ├── cubit/           # state management
│   │   └── widgets/         # widgety tej strony
│   └── widgets/             # widgety współdzielone w module
├── routing/
│   └── routes.dart          # definicje tras + buildery (getSubtree)
└── <module>_module.dart     # manifest modułu
test/                        # testy lustrują strukturę lib/
```

Nazewnictwo plików: `<page>_page.dart`, `<name>_cubit.dart`, `<name>_state.dart`,
`<name>_presentation_event.dart`, `<module>_module.dart`.

---

## 3. State management — Bloc / Cubit + Hooks

- **Cubit** preferowany; **Bloc** tylko gdy potrzebne transformacje strumienia zdarzeń
  (debounce, throttle, concurrency — `bloc_concurrency`).
- Warto opakować bazowe `Cubit`/`Bloc` we własną klasę bazową z mixinem prezentacyjnym
  (np. `bloc_presentation`), żeby ujednolicić obsługę zdarzeń „jednorazowych”.
- **Stany** `extends Equatable` z nadpisanym `props` (porównywalność, mniej zbędnych rebuildów).
- **Hooks** (`flutter_hooks` + `hooked_bloc`): cubit rozwiązujemy przez `useBloc<MyCubit>()`
  (z DI/GetIt), a nie `BlocProvider(create:)`. `BlocProvider.value` tylko gdy przekazujemy
  istniejący cubit z rodzica do dziecka.
- **Zdarzenia prezentacyjne** (snackbar, dialog, nawigacja): osobny sealed
  `<name>_presentation_event.dart` + `emitPresentation(event)`; strona nasłuchuje
  `cubit.presentation` i wywołuje callbacki nawigacji.
- **Wzorce stanu** (wybór wg potrzeby):
  1. sealed class z podklasami `Initial` / `Loading` / `Success` / `Error`,
  2. jedna klasa z nullowalnymi polami + `copyWith`,
  3. jedna klasa ze statusem (enum).
- **Formularze**: osobny `*_form_cubit.dart` obok głównego cubita.
- **UseCase** tylko gdy logika wykracza poza wywołanie jednej metody serwisu/repo, albo gdy
  wiele komponentów potrzebuje tego samego reaktywnego wyniku.

---

## 4. Dependency Injection — Injectable + GetIt

- `@injectable` dla serwisów, use case'ów, cubitów.
- `@LazySingleton(as: Interface)` dla singletonów z interfejsem (DIP).
- Rejestracja per-moduł generowana przez `injectable_generator` (`*.module.dart`),
  agregowana w app.
- **Nie edytujemy ręcznie** plików generowanych (`*.config.dart`, `*.module.dart`).
- Po zmianach: `melos gen` / `build_runner build --delete-conflicting-outputs`.

---

## 5. Routing — go_router

- **GoRouter** z nazwanymi trasami. Stałe trasy (`path`, `name`) trzymamy w jednej klasie
  obok `getSubtree` danego modułu.
- Każdy moduł eksponuje `getSubtree(path, name, { required NavigationCallback onGoToX, ... })`
  zwracające `List<RouteBase>`; app łączy poddrzewa w główny router.
- **Strony nie wołają `context.go/push` do tras z innych modułów.** Dostają **callbacki**
  nawigacyjne (np. `onLoginSuccess`, `onGoToHome`), a wiązanie tras następuje w `routes.dart`
  modułu w `builder` (np. `onGoToHome: (ctx) => ctx.goNamed(HomeRoutes.home.name)`).
- `pushNamed` gdy użytkownik może się cofnąć (detale); `goNamed` gdy podmieniamy flow.
- Parametry path/query czytane w `builder` z `GoRouterState`. Nigdy nie hardkodujemy ścieżek —
  używamy stałych i `*Named`.
- Wsparcie deep linków (universal links / app links) konfigurowane na poziomie app.

---

## 6. Warstwa sieciowa — Dio + Retrofit + JSON Serializable

- **HTTP**: **Dio** jako klient + **Retrofit** (`@RestApi()`) do deklaratywnych endpointów
  w `data/data_source/`.
- **Interceptory Dio** dla cross-cutting: auth/nagłówki, logowanie, retry, refresh — rejestrowane
  przez DI z odpowiednimi kwalifikatorami (np. osobny Dio per API).
- **DTO**: `@JsonSerializable(createToJson: false)` (jeśli tylko parsujemy odpowiedzi),
  `@JsonKey(name: ...)` tylko gdy nazwy się różnią. Kodegen przez `json_serializable`.
- **Mappery** jako extension na DTO: `extension UserDtoMapper on UserDto { User toDomain() }`.
  Warstwa domeny nie zna DTO.
- **Enumy API**: pole `apiCode` + statyczny `fromCode(String?)` z obsługą null/unknown.
- **Polimorficzne DTO**: nieznany typ → sentinel `_Unknown`, **nigdy** wyjątek.
- **Obsługa błędów**: zwracamy `Either<Error, Success>` (typy `Success`/`Failure`),
  wyjątki łapiemy i raportujemy przez wspólny handler (np. `silentlyReportError`).
  Awarie sieci/zewnętrznych usług **degradują się łagodnie** (UI pokazuje stan błędu, app nie crashuje).
- **Serwisy zamiast repozytoriów** jako warstwa abstrakcji: interfejs w `domain/service/`,
  implementacja w `data/service/`. (Konwencja nazewnicza — można równie dobrze nazywać je repozytoriami.)

---

## 7. Design System

- Osobny moduł `design_system` (zależny tylko od `core`) z komponentami `Dor*`/prefiks projektu:
  scaffoldy, karty, przyciski, pola tekstowe, dialogi, bottom sheety, loadery, error boxy, snackbary.
- **Tokeny designu** (spacing, kolory, typografia, promienie) wystawiane przez rozszerzenia na
  `BuildContext`: `context.colors`, `context.typography`, `context.spacing`, `context.designSystem`.
- **Zakaz hardkodowania** kolorów, rozmiarów fontów, marginesów — zawsze przez tokeny.
- Spacing jako skala nazwana (`xxs`, `xs`, `s`, `sm`, `m`...), nie magiczne liczby.
- Ikony: SVG przez `flutter_svg` / generowane `Assets.gen` (flutter_gen) — nie `Icon(Icons.*)`
  dla ikon nawigacyjnych marki.
- Layout testowany przy skali fontu 2x/3x (brak clippingu, brak sztywnych wysokości pod tekstem).
- Opcjonalnie moduł-katalog komponentów (`f_component_catalog`) jako żywa dokumentacja/storybook.

---

## 8. Warstwa prezentacji — dobre praktyki

- **HookWidget** zamiast `StatefulWidget` dla lokalnego stanu.
- Prywatne widgety (prefiks `_`) dla złożonych sekcji w tym samym pliku.
- `const` konstruktory i literały gdzie się da; `build()` cienki — bez async/parsowania/ciężkich
  obliczeń, bez tworzenia nowych domknięć.
- Listy: `ListView.builder` / `.separated` (nigdy `ListView(children:)` dla list dynamicznych);
  `itemExtent`/`prototypeItem` gdy znana wysokość.
- Wydajność: unikać `Opacity` (woli `withOpacity` na kolorze), `IntrinsicHeight/Width`
  (woli jawne ograniczenia), `ClipRRect` gdy wystarczy `BoxDecoration.borderRadius`; `ColoredBox`/
  `DecoratedBox` zamiast `Container`. `RepaintBoundary`/`Key` tylko gdy profil tego wymaga.
- Dziel widgety wg częstotliwości zmian, żeby rebuildowały się tylko zmieniające się fragmenty.

---

## 9. Formularze — Formz

- **`formz`** do walidacji: pola jako `FormzInput`, stan formularza z `FormzMixin`.
- Wydzielony moduł walidacji (`d_form_validation`) z gotowymi polami wielokrotnego użytku:
  email (wymagany/opcjonalny), hasło, checkbox, min/max długość, zakres liczbowy itd.
- Logika formularza w osobnym cubicie (`*_form_cubit.dart`).

---

## 10. Lokalizacja (i18n)

- **Zawsze** tłumaczymy stringi widoczne dla użytkownika — żadnych hardkodów.
- Źródło prawdy: pliki `.arb` (np. w dedykowanym module `d_translations`), generowanie klas przez
  `intl_utils` (`flutter pub global run intl_utils:generate`).
- Użycie przez rozszerzenie kontekstu: `context.strings.key_name` / `Strings.of(context)`.
- Placeholdery: `"hello": "Hello, {name}!"` → `context.strings.hello(name: ...)`.
- Klucze **snake_case**, grupowane per strona; **nie reużywamy** tego samego klucza między stronami.
- Konwencja prefiksów kluczy: `f_<modul>_<strona>_...`, `d_<modul>_...`, `design_system_...`, `app_...`.
- Każdy moduł deklaruje własną klasę `flutter_intl` w `pubspec.yaml`; nie importujemy stringów
  z innych modułów. Nieużywane klucze usuwamy.
- Można spiąć z zewnętrznym narzędziem do zarządzania tłumaczeniami (np. SimpleLocalize) przez plik
  konfiguracyjny.

---

## 11. Logowanie i diagnostyka

- **Talker** (`talker_flutter`, `talker_dio_logger`, `talker_bloc_logger`) jako warstwa logowania:
  logi sieciowe (Dio), logi bloców oraz ekran/historia logów (przydatne w debug menu).
- Alternatywnie/uzupełniająco lekki logger (`fimber`).
- Dedykowane **debug menu** (`f_debug_menu`) do podglądu logów, feature flag, środowisk — tylko
  w buildach nieprodukcyjnych.
- Centralny error handler raportujący nieobsłużone błędy do crash reportingu (z degradacją łagodną).

---

## 12. Generowanie kodu (codegen)

Pakiety oparte na `build_runner`:

- `injectable_generator` — DI,
- `retrofit_generator` — klienci HTTP,
- `json_serializable` — (de)serializacja DTO,
- `flutter_gen_runner` — typowane assety (`Assets.gen`),
- `mockito` (build_runner) — mocki do testów.

Komenda: `melos gen` → `build_runner build --delete-conflicting-outputs` we wszystkich pakietach.
Plików generowanych (`*.g.dart`, `*.config.dart`, `*.module.dart`, `*.mocks.dart`, `*.gen.dart`)
**nie edytujemy ręcznie** i wykluczamy z analizy/formatowania.

> ⚠️ Uwaga na korytarz wersji: paczki codegen muszą być kompatybilne z wersją `analyzer` zgodną
> z używanym Flutter SDK. Po bumpie SDK weryfikuj wersje generatorów.

---

## 13. Testy

- **Unit testy** logiki biznesowej (cubity, serwisy, mappery).
- **`bloc_test`** dla cubitów/blocków, **`mockito`** do mockowania zależności.
- Testujemy happy path **i** scenariusze błędów; mockujemy zależności zewnętrzne.
- Opisowe nazwy testów (co i kiedy ma się zdarzyć).
- Testy lustrują strukturę `lib/`.
- Mocki regenerujemy przed commitem (`melos gen`).
- **Pokrycie** liczone per-moduł (`melos coverage` → lcov), z możliwością raportu w PR.

---

## 14. Tooling / skrypty

Stałe komendy Melos (skrypty w `melos.yaml`):

```bash
melos bootstrap   # instalacja zależności wszystkich pakietów + linkowanie
melos get         # flutter pub get wszędzie
melos gen         # build_runner build --delete-conflicting-outputs wszędzie
melos analyze     # flutter analyze wszędzie
melos test        # testy wszędzie
melos coverage    # pokrycie wszędzie
melos clean       # flutter clean wszędzie
```

Skrypty pomocnicze (`tools/`):

- `create_module.sh <name>` — generuje nowy moduł z `module_template` (kopiuje, podmienia nazwy,
  dopina do app).
- `module_graph/` — generuje graf zależności modułów (`module_graph.md`, diagram Mermaid)
  i pozwala wykrywać złamane granice zależności.
- `agent_action.sh analyze|test [ścieżka]` — wrapper na analyze/test (per projekt lub per moduł).
- `calculate_coverage.sh` + `post_coverage_comment.sh` — pokrycie i komentarz w PR.
- `replace_name.sh` — inicjalizacja świeżego projektu z template (podmiana nazwy aplikacji/pakietu).

**Zarządzanie wersją Flutter**: **FVM** (`.fvmrc`) — pinujemy wersję SDK per projekt, żeby cały
zespół i CI używały tej samej.

---

## 15. CI/CD — GitHub Actions

Preferencja: **darmowe GitHub Actions** (zamiast płatnych usług typu Codemagic).

Minimalny pipeline na PR (`runs-on: ubuntu-latest`):

1. `actions/checkout@v4`
2. Setup Flutter (np. `subosito/flutter-action`) — z wersją z `.fvmrc`/`pubspec`.
3. `melos bootstrap`
4. `melos gen` (jeśli codegen nie jest commitowany)
5. `melos analyze` — lint/analyzer musi przejść (zero warningów).
6. `melos test` (+ ewentualnie `melos coverage` i komentarz pokrycia w PR).

Dodatkowo warto:

- Cache `~/.pub-cache` i artefaktów buildu (`actions/cache`) dla szybszych runów.
- Buildy release (Android `appbundle`, iOS) na tag/merge do `main` — z sekretami w GitHub Secrets.
  iOS wymaga runnera macOS (uważać na limity darmowych minut — macOS liczy się drożej).
- Ochrona brancha `main`: wymagane zielone checki + review.
- Skrypt inicjalizacyjny (rename projektu) jako `workflow_dispatch` przy starcie z template.

---

## 16. Standardy kodu i lint

Rygorystyczny `analysis_options.yaml` (egzekwowany w CI). Kluczowe ustawienia:

- **Formatowanie**: 2 spacje, pojedyncze cudzysłowy, trailing commas w multi-line,
  `dart format` z `page_width: 120`, dokładnie jedna pusta linia na końcu pliku.
- **Analyzer strict**: `strict-casts`, `strict-inference`, `strict-raw-types`.
- **Importy**: zawsze `package:` (`always_use_package_imports`).
- **Typowanie**: `always_declare_return_types`, `always_specify_types`, `type_annotate_public_apis`.
- **Immutability/const**: `prefer_const_*`, `use_named_constants`.
- **Bezpieczeństwo async**: `unawaited_futures`, `avoid_void_async`, `cancel_subscriptions`,
  `close_sinks`.
- **Jakość**: `only_throw_errors`, `avoid_dynamic_calls`, `prefer_final_locals`,
  `require_trailing_commas`, `unreachable_from_main`, `use_colored_box`, `use_decorated_box`.
- **Wykluczenia z analizy**: pliki generowane (`*.g.dart`, `*.mocks.dart`, `*.module.dart`,
  `generated/**`).
- Nazewnictwo opisowe (bez `e`, `i`, `x` poza prostymi licznikami), `is` zamiast porównań
  `runtimeType`, `final` dla niereassignowanych zmiennych lokalnych.

---

## 17. Rekomendowany stack (paczki uniwersalne)

| Obszar               | Paczki                                                                                             |
| -------------------- | -------------------------------------------------------------------------------------------------- |
| Monorepo             | `melos`                                                                                            |
| State management     | `bloc`, `flutter_bloc`, `bloc_concurrency`, `bloc_presentation`                                    |
| Hooks                | `flutter_hooks`, `hooked_bloc`                                                                     |
| DI                   | `injectable`, `get_it` (+ `injectable_generator`)                                                  |
| Routing              | `go_router`                                                                                        |
| HTTP                 | `dio`, `retrofit` (+ `retrofit_generator`)                                                         |
| Serializacja         | `json_annotation` + `json_serializable`                                                            |
| Modele/równość       | `equatable`, `collection`                                                                          |
| Formularze           | `formz`                                                                                            |
| Lokalizacja          | `intl`, `flutter_localizations`, `intl_utils`                                                      |
| Logowanie            | `talker_flutter`, `talker_dio_logger`, `talker_bloc_logger` (lub `fimber`)                         |
| Assety/ikony         | `flutter_svg`, `flutter_gen` (`flutter_gen_runner`)                                                |
| Sieć/łączność        | `connectivity_plus`, `internet_connection_checker_plus`                                            |
| Platforma/urządzenie | `package_info_plus`, `permission_handler`, `url_launcher`, `webview_flutter`, `shared_preferences` |
| UI startowy          | `flutter_native_splash`, `flutter_launcher_icons`                                                  |
| Codegen/testy        | `build_runner`, `mockito`, `bloc_test`                                                             |

> Paczki specyficzne dla danego projektu (lokalna baza danych, mapy, kamera, geolokalizacja,
> dostawca auth/analytics/push, secure storage) **dobieramy per projekt** — nie są częścią
> uniwersalnego fundamentu.

---

## 18. Checklista startu nowego projektu

1. Sklonuj template, uruchom skrypt rename (nazwa app + bundle/package id).
2. Ustaw wersję SDK w FVM (`.fvmrc`) i `pubspec` (`environment.flutter`).
3. `melos bootstrap`.
4. Zostaw moduły bazowe: `app`, `core`, `design_system`, `module_template`,
   `d_translations`, `d_form_validation`. Resztę dodawaj `create_module.sh`.
5. Skonfiguruj design tokens (kolory/typografia/spacing) w `design_system`.
6. Skonfiguruj `analysis_options.yaml` (jak wyżej) i sprawdź `melos analyze`.
7. Dodaj pipeline GitHub Actions (bootstrap → gen → analyze → test).
8. Ustaw splash i ikony (`flutter_native_splash`, `flutter_launcher_icons`).
9. Skonfiguruj routing root w `app` (zbieranie `getSubtree` z modułów + guardy/observery).
10. Skonfiguruj DI root (agregacja modułów Injectable) i warstwę sieciową (Dio + interceptory).
    </content>
    </invoke>
