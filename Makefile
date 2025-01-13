format:
	dart format . --line-length 120 --set-exit-if-changed

format-fix:
	dart format . --line-length 120

ios-install:
	cd ios/; pod install; cd ..

ios-build:
	make clean
	flutter build ios

android-build:
	make clean
	flutter build appbundle

lint:
	flutter analyze

riverpod-lint:
	dart run custom_lint

test:
	flutter test
.PHONY: test

test-coverage:
	flutter test --coverage --dart-define=NO_LOG=true
	flutter test --flavor=dev --merge-coverage integration_test
	sh scripts/coverage_cleanup.sh
	genhtml coverage/lcov.info -o coverage/html --rc genhtml_hi_limit=80 --rc genhtml_med_limit=50 --rc lcov_function_coverage=0 --rc genhtml_no_source=1

test-genhtml:
	genhtml -o coverage/html coverage/lcov.info

packages-outdated:
	flutter pub outdated

packages-upgrade:
	flutter pub upgrade

clean:
	flutter clean
	flutter pub get
	make build-runner
	make l10n
	flutter pub get

deep-clean:
	flutter clean
	flutter pub cache clean --force
	flutter pub get
	make build-runner
	make l10n
	flutter pub get

build-runner:
	flutter pub run build_runner build --delete-conflicting-outputs

l10n:
	flutter gen-l10n --arb-dir lib/src/core/i18n --template-arb-file common_en.arb --output-localization-file common_localizations.dart --output-class CommonLocalizations
	flutter gen-l10n --arb-dir lib/src/features/calendar/i18n --template-arb-file calendar_en.arb --output-localization-file calendar_localizations.dart --output-class CalendarLocalizations
	flutter gen-l10n --arb-dir lib/src/features/chat/i18n --template-arb-file chat_en.arb --output-localization-file chat_localizations.dart --output-class ChatLocalizations
	flutter gen-l10n --arb-dir lib/src/features/cross_content_hub/i18n --template-arb-file cross_content_hub_en.arb --output-localization-file cross_content_hub_localizations.dart --output-class CrossContentHubLocalizations
	flutter gen-l10n --arb-dir lib/src/features/home/i18n --template-arb-file home_en.arb --output-localization-file home_localizations.dart --output-class HomeLocalizations
	flutter gen-l10n --arb-dir lib/src/features/login/i18n --template-arb-file login_en.arb --output-localization-file login_localizations.dart --output-class LoginLocalizations
	flutter gen-l10n --arb-dir lib/src/features/news/i18n --template-arb-file news_en.arb --output-localization-file news_localizations.dart --output-class NewsLocalizations
	flutter gen-l10n --arb-dir lib/src/features/tos/i18n --template-arb-file tos_en.arb --output-localization-file tos_localizations.dart --output-class TosLocalizations

build-runner-watch:
	flutter pub run build_runner watch --delete-conflicting-outputs