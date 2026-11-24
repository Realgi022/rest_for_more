class Activity {
  final String title, description;
  const Activity(this.title, this.description);
}

const Map<String, List<Activity>> kActivities = {
  'Reading': [
    Activity('Read a few pages', 'Pick a book you enjoy and read without your phone nearby.'),
    Activity('Read something new', 'Try a short story or a chapter from a book you have not opened yet.'),
    Activity('Reread a favorite', 'Return to a passage you love and enjoy it slowly.'),
    Activity('Read by soft light', 'Find a cozy spot with warm light and read quietly.'),
  ],
  'Walking': [
    Activity('Easy walk outside', 'Leave your phone at home or in a bag and notice your surroundings.'),
    Activity('Walk to a new place', 'Choose a street or park you have not visited recently.'),
    Activity('Slow mindful walk', 'Walk slowly and pay attention to sounds and smells.'),
    Activity('Walk with someone', 'Invite a friend or family member for a phone-free stroll.'),
  ],
  'Music': [
    Activity('Listen to an album', 'Play a full album from start to finish and just listen.'),
    Activity('Play an instrument', 'Pick up an instrument and play anything that feels good.'),
    Activity('Discover new music', 'Put on music you have never heard and see how it feels.'),
    Activity('Sing along', 'Choose songs you love and sing without any screen.'),
  ],
  'Cooking': [
    Activity('Cook a simple meal', 'Make something easy and enjoy each step of it.'),
    Activity('Try a new recipe', 'Follow a printed or remembered recipe instead of a screen.'),
    Activity('Prepare a snack', 'Make a small snack slowly and eat it mindfully.'),
    Activity('Bake something', 'Bake bread, cookies or anything warm and comforting.'),
  ],
  'Exercise': [
    Activity('Gentle stretching', 'Stretch your body slowly and breathe deeply.'),
    Activity('Short workout', 'Do a simple routine you already know at your own pace.'),
    Activity('Yoga flow', 'Move through a few poses that feel calming.'),
    Activity('Bodyweight circuit', 'A few rounds of squats, push-ups and planks.'),
  ],
  'Creative activities': [
    Activity('Draw or doodle', 'Grab paper and a pen and draw whatever comes to mind.'),
    Activity('Write freely', 'Write in a notebook for a few minutes without editing.'),
    Activity('Make something by hand', 'Craft, paint or build something small.'),
    Activity('Photograph with intention', 'Look for beauty around you and notice details.'),
  ],
  'Relaxing': [
    Activity('Quiet sit', 'Sit comfortably, breathe slowly and let your mind settle.'),
    Activity('Warm drink break', 'Make tea or coffee and enjoy it without distractions.'),
    Activity('Lie down and rest', 'Close your eyes and rest, no screens and no pressure.'),
    Activity('Gentle breathing', 'Try slow breathing: in for 4, out for 6.'),
  ],
  'Spending time with others': [
    Activity('Have a real conversation', 'Talk with someone close to you, phones away.'),
    Activity('Share a meal', 'Eat together and keep phones off the table.'),
    Activity('Play a game together', 'A board game or cards, anything social and screen-free.'),
    Activity('Call or visit someone', 'Reach out to someone you have been meaning to see.'),
  ],
};