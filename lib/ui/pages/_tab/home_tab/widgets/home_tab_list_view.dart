import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/_tab/home_tab/home_tab_view_model.dart';
import 'package:flutter_market_app/ui/pages/_tab/home_tab/widgets/product_list_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeTabListView extends ConsumerStatefulWidget {
  @override
  _HomeTabListViewState createState() => _HomeTabListViewState();
}

class _HomeTabListViewState extends ConsumerState<HomeTabListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final viewModel = ref.read(homeTabViewModel.notifier);

      // `state.posts`의 마지막 게시글을 기준으로 추가 데이터 요청
      if (viewModel.state.hasMore && !viewModel.state.isLoading) {
        viewModel.loadMorePosts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeTabState = ref.watch(homeTabViewModel);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(homeTabViewModel.notifier).refreshPosts();
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= homeTabState.posts.length) {
                  if (homeTabState.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (!homeTabState.hasMore) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('모든 게시글을 불러왔습니다'),
                      ),
                    );
                  }
                  return null;
                }
                return Column(
                  children: [
                    ProductListItem(homeTabState.posts[index]),
                    const Divider(height: 20),
                  ],
                );
              },
              childCount: homeTabState.posts.length + 1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
