# Geography Games

Study games for Grade 9 Geography (CGC1D).

## Geo Review Base Camp

`index.html` is a quiz and flashcard site for Unit 1 (maps, latitude and longitude, time zones, seasons, plate tectonics) and Unit 2 (landform regions of Canada, weather and climate, climate graphs).

- Quizzes are 10 questions. Missed questions come back at the end until they're answered correctly.
- Flashcards: tap to flip, then mark each card "Got it" or "Again".
- Best scores are saved in the browser on the device you use.

## Geo Swipe

`swipe/index.html` is a phone-first card feed (same format as English Swipe) with decks for the Oct 20–22 lessons (glaciers, population patterns, soil, vegetation and the tundra), the Oct 16 lesson (earthquakes, volcanoes, the rock cycle), and two review decks that mix in Units 1 and 2.

- Swipe up through explainer cards and quick checks. Missed checks come back a few cards later.
- "Ones I've missed" replays only the questions answered wrong.
- "Progress (for parents)" in the deck menu shows sessions, best scores and weakest topics. Saved on the device only.

## Progress sync

`sync.js` (loaded by Base Camp and Geo Swipe) sends right/wrong results to a private Google Sheet, "Sebastian Geography progress", so reviews can target what gets missed. Same setup as English Games.

- Sends only a random device id, card/question ids, right/wrong, scores and timestamps. No name and nothing typed.
- The first time it runs on a device, it copies the progress already saved there. Results wait on the device while it's offline.
- `sync/Code.gs` is the add-only Apps Script receiver for the Sheet. It can't read anything back.
- Sync is off while `ENDPOINT` in `sync.js` is empty.
- Item ids: Swipe = `deck-index`, Base Camp = `deck-index` in `DATA.questions`. Always append new cards and questions at the end so the ids stay stable.

## Roblox: Geo Review Obby

`roblox/GeoReviewObby.lua` builds a 22-stage Unit 2 obstacle course. Each stage asks a question; walk through the door with the right answer.

1. In Roblox Studio, open a new Baseplate place.
2. Insert a Script into ServerScriptService and paste in the file.
3. Press Play to test, then File > Publish to Roblox.

Study practice only. Not for handing in.
