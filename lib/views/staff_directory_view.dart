import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scmp_staff_app/repositories/auth_repository.dart';
import 'package:scmp_staff_app/viewmodels/staff_viewmodel.dart';
import 'package:scmp_staff_app/di/injection.dart';
import 'package:scmp_staff_app/views/login_view.dart';

class StaffDirectoryView extends StatelessWidget {
  const StaffDirectoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<StaffViewModel>()..init(),
      child: const _StaffDirectoryContent(),
    );
  }
}

class _StaffDirectoryContent extends StatefulWidget {
  const _StaffDirectoryContent({super.key});

  @override
  _StaffDirectoryContentState createState() => _StaffDirectoryContentState();
}

class _StaffDirectoryContentState extends State<_StaffDirectoryContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
      final viewModel = context.read<StaffViewModel>();
      if (!viewModel.isPaginating && viewModel.hasMore) {
        viewModel.loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StaffViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff List'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            await getIt<AuthRepository>().logout();
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginView()),
              );
            }
          },
        ),
      ),
      body: Column(
        children: [
          if (viewModel.token != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.grey[200],
              child: Text(
                'Token: ${viewModel.token}',
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (viewModel.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red[100],
              child: Text(
                viewModel.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: viewModel.staffList.length + (viewModel.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == viewModel.staffList.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: viewModel.isPaginating
                              ? const Center(child: CircularProgressIndicator())
                              : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => viewModel.loadMore(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[800],
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Load More'),
                                  ),
                                ),
                        );
                      }

                      final staff = viewModel.staffList[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(staff.avatar),
                          onBackgroundImageError: (exception, stackTrace) {},
                          child: staff.avatar.isEmpty ? const Icon(Icons.person) : null,
                        ),
                        title: Text('${staff.firstName} ${staff.lastName}'),
                        subtitle: Text(staff.email),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
