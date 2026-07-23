from collectors.albums_collector import AlbumsCollector
from collectors.top_artists_collector import TopArtistsCollector
from collectors.top_tracks_collector import TopTracksCollector
from collectors.user_profile_collector import UserProfileCollector
from collectors.recently_played_collector import RecentlyPlayedCollector
from collectors.saved_tracks_collector import SavedTracksCollector

class CollectorRunner:
    def __init__(self):
        self.user_collector = UserProfileCollector()
        self.albums_collector = AlbumsCollector()
        self.top_tracks_collector = TopTracksCollector()
        self.recently_played_collector = RecentlyPlayedCollector()
        self.top_artists_collector = TopArtistsCollector()
        self.saved_tracks_collector = SavedTracksCollector()
        self.collectors = [self.user_collector, self.albums_collector, self.top_tracks_collector, 
                           self.recently_played_collector, self.top_artists_collector, self.saved_tracks_collector]

    def run(self, arg):
        if arg == 'full':
            for collector in self.collectors:
                collector.collect()
        elif arg == 'quick':
            self.user_collector.collect()
            self.recently_played_collector.collect()
        elif arg == 'library':
            self.saved_tracks_collector.collect()
            self.albums_collector.collect()
        elif arg == 'rankings':
            self.top_tracks_collector.collect()
            self.top_artists_collector.collect()
