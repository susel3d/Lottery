# Lottery

Simple project to explore Combine framework and data propagation in SwiftUI using MV pattern without separate ViewModels classes.

Lottery is based on system where 6 numbers are bets on from 1 - 49 range. Application counts how long ago every number was drawn, then for each number “position” mean value is set which finally generates proposed future result. User can generate next proposed result and/or store it.

Knowing the probability theory.. it does not guarantee winning;)

### TODO
* Rework logic to use more Combine
* Handle errors DataModel data publisher’s chains
* More UT
