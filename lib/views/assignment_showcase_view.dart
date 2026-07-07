import 'package:flutter/material.dart';

class AssignmentShowcaseView extends StatelessWidget {
  const AssignmentShowcaseView({super.key});

  static const List<_PreviewStaff> _dummyStaff = [
    _PreviewStaff('John', 'Doe', 'john.doe@company.com'),
    _PreviewStaff('Jane', 'Smith', 'jane.smith@company.com'),
    _PreviewStaff('Alex', 'Tan', 'alex.tan@company.com'),
    _PreviewStaff('Olivia', 'Lee', 'olivia.lee@company.com'),
    _PreviewStaff('Ethan', 'Goh', 'ethan.goh@company.com'),
    _PreviewStaff('Sophia', 'Chan', 'sophia.chan@company.com'),
    _PreviewStaff('Noah', 'Lim', 'noah.lim@company.com'),
    _PreviewStaff('Emma', 'Teo', 'emma.teo@company.com'),
    _PreviewStaff('Lucas', 'Ong', 'lucas.ong@company.com'),
    _PreviewStaff('Ava', 'Ng', 'ava.ng@company.com'),
    _PreviewStaff('Mia', 'Koh', 'mia.koh@company.com'),
    _PreviewStaff('Liam', 'Yap', 'liam.yap@company.com'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        title: const Text('SCMP Feature Descriptions'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Feature descriptions',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '1. Login Authentication Page',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _FeatureSection(
                phoneChild: const _LoginPhonePreview(),
                bullets: const [
                  'Simple UI for email and password input and action button',
                  'Email validation',
                  'Masked password (Constraint: letter and number only, 6-10 characters)',
                  'Indicator for API loading',
                  'Route to the Staff Directory page once login is successful',
                  'Error handling (Display a simple error message with action buttons)',
                ],
              ),
              const SizedBox(height: 24),
              Text(
                '2. Staff Directory Page',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _FeatureSection(
                phoneChild: _StaffPhonePreview(staff: _dummyStaff),
                bullets: const [
                  'Display the login token at the top of a page',
                  'Display a list of staff information (List item should contain at least avatar, email, first and last name)',
                  'Show “Load more” UI when reaching the bottom of the current page until no next page of data available',
                  'Trigger API call to load data in next page and expend the data at the bottom of the list without re-rendering the whole list',
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureSection extends StatelessWidget {
  const _FeatureSection({
    required this.phoneChild,
    required this.bullets,
  });

  final Widget phoneChild;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54),
        color: Colors.white,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 760;
          final phonePane = Container(
            width: stacked ? double.infinity : 310,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              border: stacked
                  ? const Border(bottom: BorderSide(color: Colors.black54))
                  : const Border(right: BorderSide(color: Colors.black54)),
            ),
            child: Center(child: _MockPhoneFrame(child: phoneChild)),
          );

          final descriptionPane = Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bullets
                  .map((bullet) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 7),
                              child: Icon(Icons.circle, size: 8),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                bullet,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          );

          if (stacked) {
            return Column(
              children: [
                phonePane,
                descriptionPane,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              phonePane,
              Expanded(child: descriptionPane),
            ],
          );
        },
      ),
    );
  }
}

class _MockPhoneFrame extends StatelessWidget {
  const _MockPhoneFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      height: 300,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 20),
                  Expanded(child: child),
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 68,
                  height: 14,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Positioned(
                top: 8,
                left: 10,
                child: Text(
                  '9:41 AM',
                  style: TextStyle(fontSize: 7, fontWeight: FontWeight.w600),
                ),
              ),
              const Positioned(
                top: 8,
                right: 10,
                child: Text(
                  '100%',
                  style: TextStyle(fontSize: 7, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginPhonePreview extends StatefulWidget {
  const _LoginPhonePreview();

  @override
  State<_LoginPhonePreview> createState() => _LoginPhonePreviewState();
}

class _LoginPhonePreviewState extends State<_LoginPhonePreview> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _errorMessage;
  bool _loggedIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (value.isEmpty) {
      return 'Email is required';
    }
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email';
    }
    return null;
  }

  String? _validatePassword(String value) {
    final passwordRegex = RegExp(r'^[a-zA-Z0-9]+$');
    if (value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6 || value.length > 10) {
      return '6-10 characters only';
    }
    if (!passwordRegex.hasMatch(value)) {
      return 'Letters and numbers only';
    }
    return null;
  }

  Future<void> _submit() async {
    final emailError = _validateEmail(_emailController.text.trim());
    final passwordError = _validatePassword(_passwordController.text);

    if (emailError != null) {
      setState(() {
        _errorMessage = emailError;
      });
      return;
    }

    if (passwordError != null) {
      setState(() {
        _errorMessage = passwordError;
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _loading = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
      _loggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loggedIn) {
      return _StaffPhonePreview(
        staff: AssignmentShowcaseView._dummyStaff,
        showBackButton: true,
        onBack: () {
          setState(() {
            _loggedIn = false;
            _errorMessage = null;
          });
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            'LOGIN',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _emailController,
            style: const TextStyle(fontSize: 8.5),
            decoration: _inputDecoration('Email Address'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(fontSize: 8.5),
            decoration: _inputDecoration('Password'),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 28,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                _loading ? 'Signing in...' : 'Log In',
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_loading)
            const Column(
              children: [
                Text('Logging in...', style: TextStyle(fontSize: 7.5)),
                SizedBox(height: 8),
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ),
          if (_errorMessage != null && !_loading)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                color: const Color(0xFFF8F8F8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      'Error: $_errorMessage',
                      style: const TextStyle(fontSize: 6.8),
                    ),
                  ),
                  const SizedBox(width: 4),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(24, 16),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('OK', style: TextStyle(fontSize: 6.5)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      isDense: true,
      hintText: label,
      hintStyle: const TextStyle(fontSize: 7.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: Colors.black26),
      ),
    );
  }
}

class _StaffPhonePreview extends StatefulWidget {
  const _StaffPhonePreview({
    required this.staff,
    this.showBackButton = false,
    this.onBack,
  });

  final List<_PreviewStaff> staff;
  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  State<_StaffPhonePreview> createState() => _StaffPhonePreviewState();
}

class _StaffPhonePreviewState extends State<_StaffPhonePreview> {
  static const int _pageSize = 6;
  int _visibleCount = _pageSize;
  bool _loadingMore = false;

  bool get _hasMore => _visibleCount < widget.staff.length;

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) {
      return;
    }
    setState(() {
      _loadingMore = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) {
      return;
    }
    setState(() {
      _visibleCount = (_visibleCount + _pageSize).clamp(0, widget.staff.length);
      _loadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleStaff = widget.staff.take(_visibleCount).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 18,
                child: widget.showBackButton
                    ? IconButton(
                        onPressed: widget.onBack,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 10),
                      )
                    : const SizedBox.shrink(),
              ),
              const Expanded(
                child: Text(
                  'Staff List',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 18),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            color: Colors.grey.shade200,
            child: const Text(
              'Login token: local-sqlite-session',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 6.5),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final staff = visibleStaff[index];
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: index.isEven
                          ? Colors.black
                          : Colors.white,
                      foregroundColor:
                          index.isEven ? Colors.white : Colors.black,
                      child: Text(
                        staff.firstName.characters.first,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${staff.firstName} ${staff.lastName}',
                            style: const TextStyle(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            staff.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 6.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: visibleStaff.length,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 24,
            child: ElevatedButton(
              onPressed: _hasMore && !_loadingMore ? _loadMore : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
                padding: EdgeInsets.zero,
              ),
              child: _loadingMore
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _hasMore ? 'Load More' : 'No More Data',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewStaff {
  const _PreviewStaff(this.firstName, this.lastName, this.email);

  final String firstName;
  final String lastName;
  final String email;
}
