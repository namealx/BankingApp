# BankingApp 🏦

Мобильное банковское приложение для iOS, разработанное в рамках лабораторной работы №9 по дисциплине «Технологии программирования для мобильных приложений».

---

## Description

BankingApp — iOS-приложение на Swift + SwiftUI, позволяющее клиентам банка управлять счетами, выполнять переводы между ними, просматривать курсы валют, находить ближайшие отделения на карте и редактировать профиль. Данные хранятся локально в базе данных SQLite; настройки и сессия — в UserDefaults. Приложение локализовано на русский, английский и белорусский языки.

**Основные возможности:**
- Регистрация и вход по логину/паролю; сохранение сессии
- Просмотр активных и заблокированных счетов (текущий, сберегательный, кредитный, карт-счёт с овердрафтом)
- Переводы между счетами с конвертацией валют через BYN
- Курсы 7 валют (USD, EUR, RUB, GBP, CNY, PLN, UAH) и встроенный конвертер
- Карта отделений банка с геолокацией и поиском ближайшего (MapKit)
- Редактирование профиля, смена аватара, смена пароля
- Переключение темы (светлая / тёмная / системная) и языка интерфейса

---

## Installation

**Требования:**
- macOS Tahoe 26.2+
- Xcode 26.5+
- iOS Simulator: iPhone 17 Pro, iOS 26.5 (или физическое устройство iPhone 17 Pro)

**Шаги:**

```bash
# 1. Клонировать репозиторий
git clone https://github.com/namealx/BankingApp.git
cd BankingApp

# 2. Открыть проект в Xcode
open BankingApp.xcodeproj
```

3. В Xcode выбрать схему **BankingApp** и симулятор **iPhone 15**.
4. Нажать **Cmd + R** для сборки и запуска.

> Сторонние зависимости не используются (SQLite.swift подключён через Swift Package Manager и подтягивается автоматически при открытии проекта).

---

## Usage

**Вход в приложение:**
- Нажать кнопку **Demo** — поля логина и пароля заполнятся автоматически (`demo` / `demo123`)
- Либо ввести логин и пароль вручную и нажать «Войти»
- Для создания нового аккаунта — «Нет аккаунта? Зарегистрироваться»

**Навигация (Tab Bar):**

| Вкладка | Функция |
|---|---|
| Счета | Просмотр всех счетов, суммарного баланса, детали счёта |
| Переводы | Перевод средств между счетами с конвертацией |
| Валюты | Курсы валют, конвертер, избранные валюты |
| Карта | Отделения банка, геолокация, маршрут |
| Профиль | Данные профиля, смена пароля, настройки, выход |

**Переключение языка:** Профиль → Настройки → Язык приложения (Русский / English / Беларуская)

**Переключение темы:** Профиль → Настройки → Тема (Системная / Светлая / Тёмная)

---

## Running Tests

```bash
# Unit-тесты
xcodebuild test \
  -scheme BankingApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' \
  -only-testing:BankingAppTests \
  CODE_SIGNING_ALLOWED=NO

# UI-тесты
xcodebuild test \
  -scheme BankingApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' \
  -only-testing:BankingAppUITests \
  CODE_SIGNING_ALLOWED=NO
```

Или в Xcode: **Cmd + U** для запуска всех тестов по Test Plan.

**Статус тестов:** [![iOS CI](https://github.com/namealx/BankingApp/actions/workflows/ios-ci.yml/badge.svg)](https://github.com/namealx/BankingApp/actions)

| Тип тестов | Количество | Статус |
|---|---|---|
| Unit Tests (XCTest) | 20 | ✅ All passing |
| UI Tests (XCTest) | 20 | ✅ All passing |

---

## Project Structure

```
BankingApp/
├── BankingApp.swift               # Точка входа (@main)
├── String+Localized.swift         # Расширение .localized
├── Models/
│   └── Models.swift               # User, Account, Transaction, Branch, CurrencyRate
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── AccountsViewModel.swift
│   ├── TransferViewModel.swift
│   ├── CurrencyViewModel.swift
│   ├── BranchViewModel.swift
│   └── ProfileViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── MainTabView.swift
│   ├── Auth/AuthViews.swift
│   ├── Accounts/AccountsView.swift
│   ├── Transfer/TransferView.swift
│   ├── Currency/CurrencyView.swift
│   ├── Map/BranchMapView.swift
│   └── Profile/ProfileView.swift
├── Services/
│   ├── DatabaseManager.swift      # SQLite (4 таблицы, CRUD, транзакции)
│   └── SettingsManager.swift      # UserDefaults (сессия, тема, язык)
└── Resources/
    ├── ru.lproj/Localizable.strings
    ├── en.lproj/Localizable.strings
    └── be.lproj/Localizable.strings

BankingAppTests/
└── BankingAppTests.swift          # 20 Unit-тестов

BankingAppUITests/
└── BankingAppUITests.swift        # 20 UI-тестов

.github/
└── workflows/
    └── ios-ci.yml                 # GitHub Actions CI/CD
```

---

## Technologies

| Технология | Версия / Назначение |
|---|---|
| Swift | 6.3 |
| SwiftUI | iOS 26.5 SDK |
| SQLite.swift | 0.15.3+ — хранение данных |
| UserDefaults | Настройки и сессия |
| MVVM | Архитектурный шаблон |
| XCTest | Unit- и UI-тестирование |
| MapKit + CoreLocation | Карта отделений |
| GitHub Actions | CI/CD (сборка + тесты) |

---

## CI/CD

Настроен пайплайн GitHub Actions (`.github/workflows/ios-ci.yml`):
- Запускается при каждом push и Pull Request в ветки `main` и `develop`
- Выполняет Unit-тесты → UI-тесты → Release-сборку
- Merge в `main` возможен только при зелёном статусе CI

---

## Contributing

**Состав команды и распределение задач:**

| Участник | Роль | Задачи |
|---|---|---|
| Юранов Никита | Тимлид / Разработчик | Весь код (Models, ViewModels, Services, Views), Unit- и UI-тесты, CI/CD, README, .gitignore |
| Иван Насенник | Аналитик / Проектировщик | Спецификация требований (REQUIREMENTS.md), UML-диаграммы (Use Case, Class, Sequence, Activity, ER, Component, Package, Deployment, Physical ERD), макеты Figma, Wiki (8 страниц), презентация проекта |

Разработка ведётся по модели Feature Branch: функции реализуются в ветках `feature/*`, мержатся в `develop` через Pull Request, в `main` — только протестированные версии.


