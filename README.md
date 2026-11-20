# Mandiri Movies

Native iOS app (SwiftUI + VIPER) using [TMDB API](https://api.themoviedb.org).

## Flow

**Genres** → **Movies by genre** (endless scroll) → **Movie detail** (info, cast, trailer, reviews)

## User stories

1. Official genres list  
2. Discover movies by genre  
3. Primary movie info on tap  
4. User reviews (endless scroll)  
5. YouTube trailer  
6. Endless scroll on movies + reviews  
7. Positive and negative unit tests  

## Setup

```bash
cd mandiri-movies
cp .env.example .env   # set API_KEY=
xcodegen generate
open MandiriMovies.xcodeproj
```

## Tests

```bash
xcodebuild -scheme MandiriMovies \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  test
```
