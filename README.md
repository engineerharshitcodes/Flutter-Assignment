# Pokédex Flutter App

A Flutter Pokédex application built using live data from the PokéAPI.

## Features

- Browse Pokémon with pagination
- Search Pokémon from currently loaded results
- Pokémon details
- Official Pokémon artwork
- Pokémon types
- Height and weight
- Abilities
- Base stats
- Favorite Pokémon
- Persistent favorites using local storage
- Favorites synchronized between Home, Details and Favorites screens
- Loading and error states
- Retry functionality
- Empty search and empty favorites states

## Tech Stack

- Flutter
- Dart
- Provider
- HTTP
- SharedPreferences
- PokéAPI

## API

Data is fetched from:

https://pokeapi.co/

Main endpoint:

`GET /api/v2/pokemon?limit=20&offset=0`

Details:

`GET /api/v2/pokemon/{name}`

## Project Structure

```text
lib/
├── models/
│   └── pokemon.dart
├── services/
│   └── pokemon_api.dart
├── state/
│   └── favorites_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── favorites_screen.dart
│   └── pokemon_detail_screen.dart
├── widgets/
└── theme/
└── main.dart