enum BaseSceneLayerType {
    DebugMenuSceneLayer,
    DebugSelectQuestSceneLayer,
    DebugSelectStorySceneLayer,
    SoundViewerSceneLayer,
    DebugSelectMysteriesSceneLayer,
    AnimeViewerSceneLayer,
    CameraSceneLayer,
    WebSceneLayer,
    StartupSceneLayer,
    PrologueSceneLayer,
    AnotherQuestSceneLayer,
    TopSceneLayer,
    EventStoryRaidSceneLayer,
    EventBranchSceneLayer,
    EventSingleRaidSceneLayer,
    EventDungeonSceneLayer,
    EventRaidSceneLayer,
    EventPuellaHistoriaSceneLayer,
    QuestBattleSceneLayer,
    QuestUnitTestSceneLayer,
    EvolutionSceneLayer,
    MemoriaSceneLayer,
    GachaSceneLayer,
    StorySceneLayer,
    StoryViewerSceneLayer,
    Live2dViewerSceneLayer,
    MovieSceneLayer,
    DownloadSceneLayer,
    DebugSelectURLSceneLayer,
    QuestStoredDataSceneLayer,
    SendReplayDataSceneLayer,
    InputTextSceneLayer,
    SpfxViewerSceneLayer,
    LoadingSceneLayer,
    ErrorSceneLayer,
    NetworkErrorSceneLayer,
    TapSceneLayer,
    EmotionBoardSceneLayer,
    GlassTapSceneLayer,
    QuestViewerSceneLayer,
    BaseSceneLayerTypeMaxValue
};

char const* BaseSceneLayerTypeStrings[] {
    "DebugMenuSceneLayer",
    "DebugSelectQuestSceneLayer",
    "DebugSelectStorySceneLayer",
    "SoundViewerSceneLayer",
    "DebugSelectMysteriesSceneLayer",
    "AnimeViewerSceneLayer",
    "CameraSceneLayer",
    "WebSceneLayer",
    "StartupSceneLayer",
    "PrologueSceneLayer",
    "AnotherQuestSceneLayer",
    "TopSceneLayer",
    "EventStoryRaidSceneLayer",
    "EventBranchSceneLayer",
    "EventSingleRaidSceneLayer",
    "EventDungeonSceneLayer",
    "EventRaidSceneLayer",
    "EventPuellaHistoriaSceneLayer",
    "QuestBattleSceneLayer",
    "QuestUnitTestSceneLayer",
    "EvolutionSceneLayer",
    "MemoriaSceneLayer",
    "GachaSceneLayer",
    "StorySceneLayer",
    "StoryViewerSceneLayer",
    "Live2dViewerSceneLayer",
    "MovieSceneLayer",
    "DownloadSceneLayer",
    "DebugSelectURLSceneLayer",
    "QuestStoredDataSceneLayer",
    "SendReplayDataSceneLayer",
    "InputTextSceneLayer",
    "SpfxViewerSceneLayer",
    "LoadingSceneLayer",
    "ErrorSceneLayer",
    "NetworkErrorSceneLayer",
    "TapSceneLayer",
    "GlassTapSceneLayer",
    "QuestViewerSceneLayer",
    "EmotionBoardSceneLayer"
};

#if defined(__arm__)
struct BaseSceneLayerInfo {
    char unk[24];
    BaseSceneLayerType layerType;
};
#elif defined(__aarch64__)
struct BaseSceneLayerInfo {
    char unk[36];
    BaseSceneLayerType layerType;
};
#endif

enum UrlConfigResourceType {
    BaseUrl,
    TrunkUrl,
    ScenarioUrl,
    UrlConfigResourceTypeMaxValue
};