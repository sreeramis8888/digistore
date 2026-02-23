// import 'package:hive_flutter/hive_flutter.dart';

// class HiveCacheService {
//   static const String _homeDataBox = 'home_data_cache';
//   static const String _feedsDataBox = 'feeds_data_cache';
//   static const String _chatDataBox = 'chat_data_cache';
//   static const String _activeCampaignKey = 'active_campaigns';
//   static const String _posterPromotionKey = 'poster_promotions';
//   static const String _upcomingEventsKey = 'upcoming_events';
//   static const String _featuredResourcesKey = 'featured_resources';
//   static const String _feedsKey = 'feeds_list';
//   static const String _feedsTotalCountKey = 'feeds_total_count';
//   static const String _feedsCurrentPageKey = 'feeds_current_page';
//   static const String _conversationsKey = 'conversations_list';
//   static const String _conversationsTotalCountKey = 'conversations_total_count';
//   static const String _conversationsCurrentPageKey =
//       'conversations_current_page';
//   static const String _membersKey = 'members_list';
//   static const String _membersTotalCountKey = 'members_total_count';
//   static const String _membersCurrentPageKey = 'members_current_page';
//   static const String _membersSearchKey = 'members_search_query';

//   late Box<dynamic> _homeBox;
//   late Box<dynamic> _feedsBox;
//   late Box<dynamic> _chatBox;

//   Future<void> init() async {
//     await Hive.initFlutter();
//     _homeBox = await Hive.openBox<dynamic>(_homeDataBox);
//     _feedsBox = await Hive.openBox<dynamic>(_feedsDataBox);
//     _chatBox = await Hive.openBox<dynamic>(_chatDataBox);
//   }

//   Future<void> cacheHomeData({
//     required List<CampaignModel> activeCampaigns,
//     required List<Promotions> posterPromotions,
//     required List<EventModel> upcomingEvents,
//     required List<ResourceModel> featuredResources,
//   }) async {
//     try {
//       await _homeBox.putAll({
//         _activeCampaignKey: activeCampaigns.map((c) => c.toJson()).toList(),
//         _posterPromotionKey: posterPromotions.map((p) => p.toJson()).toList(),
//         _upcomingEventsKey: upcomingEvents.map((e) => e.toJson()).toList(),
//         _featuredResourcesKey: featuredResources
//             .map((r) => r.toJson())
//             .toList(),
//       });
//     } catch (e) {
//       print('Error caching home data: $e');
//     }
//   }

//   Map<String, dynamic> _convertMapTypes(dynamic map) {
//     if (map is Map<String, dynamic>) return map;
//     if (map is Map) {
//       return Map<String, dynamic>.from(
//         map.map((key, value) {
//           // Recursively convert nested maps
//           if (value is Map) {
//             return MapEntry(key.toString(), _convertMapTypes(value));
//           }
//           // Convert lists of maps
//           if (value is List) {
//             return MapEntry(
//               key.toString(),
//               value.map((item) {
//                 if (item is Map) return _convertMapTypes(item);
//                 return item;
//               }).toList(),
//             );
//           }
//           return MapEntry(key.toString(), value);
//         }),
//       );
//     }
//     return {};
//   }

//   List<CampaignModel> getCachedActiveCampaigns() {
//     try {
//       final data = _homeBox.get(_activeCampaignKey) as List<dynamic>?;
//       if (data == null) return [];
//       return data
//           .map((item) => CampaignModel.fromJson(_convertMapTypes(item)))
//           .toList();
//     } catch (e) {
//       print('Error retrieving cached campaigns: $e');
//       return [];
//     }
//   }

//   List<Promotions> getCachedPosterPromotions() {
//     try {
//       final data = _homeBox.get(_posterPromotionKey) as List<dynamic>?;
//       if (data == null) return [];
//       return data
//           .map((item) => Promotions.fromJson(_convertMapTypes(item)))
//           .toList();
//     } catch (e) {
//       print('Error retrieving cached promotions: $e');
//       return [];
//     }
//   }

//   List<EventModel> getCachedUpcomingEvents() {
//     try {
//       final data = _homeBox.get(_upcomingEventsKey) as List<dynamic>?;
//       if (data == null) return [];
//       return data
//           .map((item) => EventModel.fromJson(_convertMapTypes(item)))
//           .toList();
//     } catch (e) {
//       print('Error retrieving cached events: $e');
//       return [];
//     }
//   }

//   List<ResourceModel> getCachedFeaturedResources() {
//     try {
//       final data = _homeBox.get(_featuredResourcesKey) as List<dynamic>?;
//       if (data == null) return [];
//       return data
//           .map((item) => ResourceModel.fromJson(_convertMapTypes(item)))
//           .toList();
//     } catch (e) {
//       print('Error retrieving cached resources: $e');
//       return [];
//     }
//   }

//   bool hasCachedData() {
//     return _homeBox.containsKey(_activeCampaignKey) ||
//         _homeBox.containsKey(_posterPromotionKey) ||
//         _homeBox.containsKey(_upcomingEventsKey) ||
//         _homeBox.containsKey(_featuredResourcesKey);
//   }

//   // Feeds caching methods
//   Future<void> cacheFeeds({
//     required List<FeedModel> feeds,
//     required int totalCount,
//     required int currentPage,
//   }) async {
//     try {
//       await _feedsBox.putAll({
//         _feedsKey: feeds.map((f) => f.toJson()).toList(),
//         _feedsTotalCountKey: totalCount,
//         _feedsCurrentPageKey: currentPage,
//       });
//     } catch (e) {
//       print('Error caching feeds: $e');
//     }
//   }

//   List<FeedModel> getCachedFeeds() {
//     try {
//       final data = _feedsBox.get(_feedsKey) as List<dynamic>?;
//       if (data == null) return [];
//       return data
//           .map((item) => FeedModel.fromJson(_convertMapTypes(item)))
//           .toList();
//     } catch (e) {
//       print('Error retrieving cached feeds: $e');
//       return [];
//     }
//   }

//   int getCachedFeedsTotalCount() {
//     try {
//       return _feedsBox.get(_feedsTotalCountKey) as int? ?? 0;
//     } catch (e) {
//       print('Error retrieving cached feeds total count: $e');
//       return 0;
//     }
//   }

//   int getCachedFeedsCurrentPage() {
//     try {
//       return _feedsBox.get(_feedsCurrentPageKey) as int? ?? 1;
//     } catch (e) {
//       print('Error retrieving cached feeds current page: $e');
//       return 1;
//     }
//   }

//   bool hasCachedFeeds() {
//     return _feedsBox.containsKey(_feedsKey);
//   }

//   Future<void> updateCachedFeedLike({
//     required String feedId,
//     required bool isLiked,
//     required int likeCount,
//   }) async {
//     try {
//       final cachedFeeds = getCachedFeeds();
//       final feedIndex = cachedFeeds.indexWhere((f) => f.id == feedId);

//       if (feedIndex != -1) {
//         final feed = cachedFeeds[feedIndex];
//         final updatedFeed = FeedModel(
//           id: feed.id,
//           media: feed.media,
//           content: feed.content,
//           author: feed.author,
//           authorId: feed.authorId,
//           likeCount: likeCount,
//           commentCount: feed.commentCount,
//           status: feed.status,
//           isLiked: isLiked,
//           createdAt: feed.createdAt,
//           updatedAt: feed.updatedAt,
//         );

//         cachedFeeds[feedIndex] = updatedFeed;

//         await _feedsBox.put(
//           _feedsKey,
//           cachedFeeds.map((f) => f.toJson()).toList(),
//         );
//       }
//     } catch (e) {
//       print('Error updating cached feed like: $e');
//     }
//   }

//   Future<void> clearCache() async {
//     try {
//       await _homeBox.clear();
//       await _feedsBox.clear();
//       await _chatBox.clear();
//     } catch (e) {
//       print('Error clearing cache: $e');
//     }
//   }

//   // ============ CONVERSATIONS CACHING (Legacy/Mixed) ============

//   Future<void> cacheConversations({
//     required List<ConversationModel> conversations,
//     required int totalCount,
//     required int currentPage,
//   }) async {
//     try {
//       await _chatBox.putAll({
//         _conversationsKey: conversations.map((c) => c.toJson()).toList(),
//         _conversationsTotalCountKey: totalCount,
//         _conversationsCurrentPageKey: currentPage,
//       });
//     } catch (e) {
//       print('Error caching conversations: $e');
//     }
//   }

//   List<ConversationModel> getCachedConversations() {
//     try {
//       final data = _chatBox.get(_conversationsKey) as List<dynamic>?;
//       if (data == null) return [];
//       return data
//           .map((item) => ConversationModel.fromJson(_convertMapTypes(item)))
//           .toList();
//     } catch (e) {
//       print('Error retrieving cached conversations: $e');
//       return [];
//     }
//   }

//   int getCachedConversationsTotalCount() {
//     try {
//       return _chatBox.get(_conversationsTotalCountKey) as int? ?? 0;
//     } catch (e) {
//       print('Error retrieving cached conversations total count: $e');
//       return 0;
//     }
//   }

//   int getCachedConversationsCurrentPage() {
//     try {
//       return _chatBox.get(_conversationsCurrentPageKey) as int? ?? 1;
//     } catch (e) {
//       print('Error retrieving cached conversations current page: $e');
//       return 1;
//     }
//   }

//   bool hasCachedConversations() {
//     return _chatBox.containsKey(_conversationsKey);
//   }

//   // ============ CHATS (Direct) CACHING ============
//   static const String _chatsKey = 'chats_list_v2';

//   Future<void> cacheChats({required List<ConversationModel> chats}) async {
//     try {
//       await _chatBox.put(_chatsKey, chats.map((c) => c.toJson()).toList());
//     } catch (e) {
//       print('Error caching chats: $e');
//     }
//   }

//   List<ConversationModel> getCachedChats() {
//     try {
//       final data = _chatBox.get(_chatsKey) as List<dynamic>?;
//       if (data == null) return [];
//       return data
//           .map((item) => ConversationModel.fromJson(_convertMapTypes(item)))
//           .toList();
//     } catch (e) {
//       print('Error retrieving cached chats: $e');
//       return [];
//     }
//   }

//   bool hasCachedChats() {
//     return _chatBox.containsKey(_chatsKey);
//   }

//   // ============ GROUPS CACHING ============
//   static const String _groupsKey = 'groups_list_v2';

//   Future<void> cacheGroups({required List<ConversationModel> groups}) async {
//     try {
//       await _chatBox.put(_groupsKey, groups.map((c) => c.toJson()).toList());
//     } catch (e) {
//       print('Error caching groups: $e');
//     }
//   }

//   List<ConversationModel> getCachedGroups() {
//     try {
//       final data = _chatBox.get(_groupsKey) as List<dynamic>?;
//       if (data == null) return [];
//       return data
//           .map((item) => ConversationModel.fromJson(_convertMapTypes(item)))
//           .toList();
//     } catch (e) {
//       print('Error retrieving cached groups: $e');
//       return [];
//     }
//   }

//   bool hasCachedGroups() {
//     return _chatBox.containsKey(_groupsKey);
//   }

//   // ============ MEMBERS CACHING ============

//   Future<void> cacheMembers({
//     required List<UserModel> members,
//     required int totalCount,
//     required int currentPage,
//     required String? searchQuery,
//   }) async {
//     try {
//       await _chatBox.putAll({
//         _membersKey: members.map((m) => m.toJson()).toList(),
//         _membersTotalCountKey: totalCount,
//         _membersCurrentPageKey: currentPage,
//         _membersSearchKey: searchQuery ?? '',
//       });
//     } catch (e) {
//       print('Error caching members: $e');
//     }
//   }

//   List<UserModel> getCachedMembers() {
//     try {
//       final data = _chatBox.get(_membersKey) as List<dynamic>?;
//       if (data == null) return [];
//       return data
//           .map((item) => UserModel.fromJson(_convertMapTypes(item)))
//           .toList();
//     } catch (e) {
//       print('Error retrieving cached members: $e');
//       return [];
//     }
//   }

//   int getCachedMembersTotalCount() {
//     try {
//       return _chatBox.get(_membersTotalCountKey) as int? ?? 0;
//     } catch (e) {
//       print('Error retrieving cached members total count: $e');
//       return 0;
//     }
//   }

//   int getCachedMembersCurrentPage() {
//     try {
//       return _chatBox.get(_membersCurrentPageKey) as int? ?? 1;
//     } catch (e) {
//       print('Error retrieving cached members current page: $e');
//       return 1;
//     }
//   }

//   String? getCachedMembersSearchQuery() {
//     try {
//       final query = _chatBox.get(_membersSearchKey) as String?;
//       return query?.isEmpty ?? true ? null : query;
//     } catch (e) {
//       print('Error retrieving cached members search query: $e');
//       return null;
//     }
//   }

//   bool hasCachedMembers() {
//     return _chatBox.containsKey(_membersKey);
//   }

//   Future<void> clearConversationsCache() async {
//     try {
//       await _chatBox.delete(_conversationsKey);
//       await _chatBox.delete(_conversationsTotalCountKey);
//       await _chatBox.delete(_conversationsCurrentPageKey);
//     } catch (e) {
//       print('Error clearing conversations cache: $e');
//     }
//   }

//   Future<void> clearMembersCache() async {
//     try {
//       await _chatBox.delete(_membersKey);
//       await _chatBox.delete(_membersTotalCountKey);
//       await _chatBox.delete(_membersCurrentPageKey);
//       await _chatBox.delete(_membersSearchKey);
//     } catch (e) {
//       print('Error clearing members cache: $e');
//     }
//   }
// }
