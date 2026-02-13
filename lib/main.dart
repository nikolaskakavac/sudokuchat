import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const SudokuChatApp());
}

class SudokuChatApp extends StatelessWidget {
  const SudokuChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF7A3BFF);

    return MaterialApp(
      title: 'Sudocker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: seed,
              brightness: Brightness.dark,
            ).copyWith(
              primary: seed,
              secondary: const Color(0xFFB38BFF),
              surface: const Color(0xFF14121A),
            ),
        scaffoldBackgroundColor: const Color(0xFF0D0B12),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: Color(0xFFF4F2FF),
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: Color(0xFFEAE6FF),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            height: 1.3,
            color: Color(0xFFB7B1C9),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1B1824),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2A2436)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2A2436)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF7A3BFF), width: 1.5),
          ),
          labelStyle: const TextStyle(color: Color(0xFFB7B1C9)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          hintStyle: const TextStyle(color: Color(0xFF6E6782)),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthMode _mode = AuthMode.login;
  bool _isSubmitting = false;
  static const _demoUsername = 'skale';
  static const _demoPassword = 'Lozinka123';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) {
        return;
      }

      if (_mode == AuthMode.login) {
        final username = _usernameController.text;
        final password = _passwordController.text;

        if (username != _demoUsername || password != _demoPassword) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid demo credentials.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }

      if (!mounted) {
        return;
      }

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == AuthMode.login ? AuthMode.register : AuthMode.login;
    });
  }

  String? _validateUsername(String? value) {
    final username = value ?? '';
    if (username.isEmpty) {
      return 'Username is required.';
    }

    if (username.contains(' ')) {
      return 'Username cannot contain spaces.';
    }

    if (username.length < 3 || username.length > 15) {
      return 'Username must be 3-15 characters.';
    }

    final firstChar = username[0];
    final lastChar = username[username.length - 1];
    if (firstChar == '.' ||
        firstChar == '_' ||
        lastChar == '.' ||
        lastChar == '_') {
      return 'Username cannot start or end with . or _';
    }

    int previousCode = 0;
    for (final code in username.codeUnits) {
      final char = String.fromCharCode(code);
      final isLower = code >= 97 && code <= 122;
      final isDigit = code >= 48 && code <= 57;
      final isAllowed = isLower || isDigit || char == '_' || char == '.';

      if (!isAllowed) {
        return 'Use lowercase letters, numbers, . or _ only.';
      }

      if (char == '.' && previousCode == 46) {
        return 'Dot cannot repeat.';
      }

      previousCode = code;
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required.';
    }

    if (password.contains(' ')) {
      return 'Password cannot contain spaces.';
    }

    if (password.length < 8 || password.length > 32) {
      return 'Password must be 8-32 characters.';
    }

    bool hasDigit = false;
    bool hasUpper = false;
    for (final code in password.codeUnits) {
      if (code < 33 || code > 126) {
        return 'Only ASCII 33-126 allowed.';
      }
      if (code >= 48 && code <= 57) {
        hasDigit = true;
      }
      if (code >= 65 && code <= 90) {
        hasUpper = true;
      }
    }

    if (!hasDigit || !hasUpper) {
      return 'Need at least 1 digit and 1 uppercase.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final modeLabel = _mode == AuthMode.login ? 'Login' : 'Register';

    return Scaffold(
      body: Stack(
        children: [
          const _GradientBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        'Sudocker',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Play sharp. Chat sharper.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF9A93B3),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      _ModeToggle(mode: _mode, onToggle: _toggleMode),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14121A),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF262030)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x66000000),
                              blurRadius: 28,
                              offset: Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '$modeLabel to continue',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _usernameController,
                                autocorrect: false,
                                enableSuggestions: false,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  hintText: 'lowercase, numbers, . or _',
                                ),
                                onChanged: (_) =>
                                    _formKey.currentState?.validate(),
                                validator: _validateUsername,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  hintText: '8-32 chars, 1 digit, 1 uppercase',
                                ),
                                onChanged: (_) =>
                                    _formKey.currentState?.validate(),
                                validator: _validatePassword,
                                onFieldSubmitted: (_) => _submit(),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _isSubmitting ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(modeLabel),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Username rules: 3-15 chars, lowercase + digits + . or _. No leading/trailing . or _, and no consecutive dots.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: const Color(0xFF8F88A6)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Password rules: 8-32 chars, ASCII 33-126, include 1 digit + 1 uppercase.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: const Color(0xFF8F88A6)),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Demo login: $_demoUsername / $_demoPassword',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: const Color(0xFFB9B2D4)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _toggleMode,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFD2CBFF),
                        ),
                        child: Text(
                          _mode == AuthMode.login
                              ? 'No account? Register'
                              : 'Have an account? Login',
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onToggle});

  final AuthMode mode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isLogin = mode == AuthMode.login;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1723),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Login',
              isActive: isLogin,
              color: colorScheme.primary,
              onTap: isLogin ? null : onToggle,
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'Register',
              isActive: !isLogin,
              color: colorScheme.primary,
              onTap: isLogin ? onToggle : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.isActive,
    required this.color,
    this.onTap,
  });

  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : const Color(0xFFA79FC0),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientBackdrop extends StatelessWidget {
  const _GradientBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0B0A0F), Color(0xFF14101C), Color(0xFF0D0B12)],
            ),
          ),
        ),
        Positioned(
          top: -60,
          left: -40,
          child: _BlurCircle(color: Color(0xFF6F3BFF), size: 180),
        ),
        Positioned(
          top: 120,
          right: -80,
          child: _BlurCircle(color: Color(0xFF2D1B55), size: 220),
        ),
        Positioned(
          bottom: -70,
          left: 10,
          child: _BlurCircle(color: Color(0xFFB18CFF), size: 200),
        ),
      ],
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 90),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 77),
            blurRadius: 60,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<List<int>> _given;
  late final List<List<int>> _values;
  bool _hasShownWin = false;
  int? _selectedRow;
  int? _selectedCol;

  @override
  void initState() {
    super.initState();
    _given = <List<int>>[
      [0, 0, 0, 2, 6, 0, 7, 0, 1],
      [6, 8, 0, 0, 7, 0, 0, 9, 0],
      [1, 9, 0, 0, 0, 4, 5, 0, 0],
      [8, 2, 0, 1, 0, 0, 0, 4, 0],
      [0, 0, 4, 6, 0, 2, 9, 0, 0],
      [0, 5, 0, 0, 0, 3, 0, 2, 8],
      [0, 0, 9, 3, 0, 0, 0, 7, 4],
      [0, 4, 0, 0, 5, 0, 0, 3, 6],
      [7, 0, 3, 0, 1, 8, 0, 0, 0],
    ];

    _values = List.generate(
      9,
      (row) => List.generate(9, (col) => _given[row][col]),
    );

  }

  bool _isFixed(int row, int col) => _given[row][col] != 0;

  bool _isConflict(int row, int col, int value) {
    if (value == 0) {
      return false;
    }

    for (int c = 0; c < 9; c++) {
      if (c != col && _values[row][c] == value) {
        return true;
      }
    }
    for (int r = 0; r < 9; r++) {
      if (r != row && _values[r][col] == value) {
        return true;
      }
    }

    final startRow = (row ~/ 3) * 3;
    final startCol = (col ~/ 3) * 3;
    for (int r = startRow; r < startRow + 3; r++) {
      for (int c = startCol; c < startCol + 3; c++) {
        if ((r != row || c != col) && _values[r][c] == value) {
          return true;
        }
      }
    }

    return false;
  }

  void _resetSudoku() {
    setState(() {
      _hasShownWin = false;
      _selectedRow = null;
      _selectedCol = null;
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          _values[r][c] = _given[r][c];
        }
      }
    });
  }

  void _selectCell(int row, int col) {
    if (_isFixed(row, col)) {
      return;
    }
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
  }

  void _setCellValue(int value) {
    final row = _selectedRow;
    final col = _selectedCol;
    if (row == null || col == null || _isFixed(row, col)) {
      return;
    }

    setState(() {
      _values[row][col] = value;
    });

    final solved = _isSolved();
    if (solved && !_hasShownWin && mounted) {
      _hasShownWin = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sudoku solved!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (!solved) {
      _hasShownWin = false;
    }
  }

  bool _isSolved() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final value = _values[r][c];
        if (value == 0) {
          return false;
        }
        if (_isConflict(r, c, value)) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxContentWidth = min(MediaQuery.of(context).size.width, 520.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku+Chat'),
        backgroundColor: const Color(0xFF0D0B12),
        elevation: 0,
      ),
      body: Stack(
        children: [
          const _GradientBackdrop(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Welcome back',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pick a mode to start playing or chatting.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF9A93B3),
                              ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Sudoku',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF14121A),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFF262030)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x66000000),
                                blurRadius: 28,
                                offset: Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final gridSize = min(constraints.maxWidth, 360.0);
                                  return SizedBox(
                                    height: gridSize,
                                    width: gridSize,
                                    child: GridView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 9,
                                      ),
                                      itemCount: 81,
                                      itemBuilder: (context, index) {
                                        final row = index ~/ 9;
                                        final col = index % 9;
                                        final value = _values[row][col];
                                        final isFixed = _isFixed(row, col);
                                        final isConflict = _isConflict(row, col, value);
                                        final isSelected = _selectedRow == row && _selectedCol == col;
                                        final borderColor = const Color(0xFF2A2436);
                                        final thickBorderColor = const Color(0xFF3C3350);

                                        return InkWell(
                                          onTap: () => _selectCell(row, col),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0xFF221B33)
                                                  : isConflict
                                                      ? const Color(0xFF3A1D2D)
                                                      : const Color(0xFF15131C),
                                              border: Border(
                                                top: BorderSide(
                                                  color: row % 3 == 0 ? thickBorderColor : borderColor,
                                                  width: row % 3 == 0 ? 1.4 : 0.6,
                                                ),
                                                left: BorderSide(
                                                  color: col % 3 == 0 ? thickBorderColor : borderColor,
                                                  width: col % 3 == 0 ? 1.4 : 0.6,
                                                ),
                                                right: BorderSide(
                                                  color: (col + 1) % 3 == 0 ? thickBorderColor : borderColor,
                                                  width: (col + 1) % 3 == 0 ? 1.4 : 0.6,
                                                ),
                                                bottom: BorderSide(
                                                  color: (row + 1) % 3 == 0 ? thickBorderColor : borderColor,
                                                  width: (row + 1) % 3 == 0 ? 1.4 : 0.6,
                                                ),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                value == 0 ? '' : value.toString(),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: isFixed ? FontWeight.w700 : FontWeight.w600,
                                                  color: isFixed
                                                      ? const Color(0xFFEAE6FF)
                                                      : const Color(0xFFB38BFF),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(9, (index) {
                                  final value = index + 1;
                                  return _SudokuKey(
                                    label: value.toString(),
                                    onTap: () => _setCellValue(value),
                                  );
                                }),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _resetSudoku,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: colorScheme.primary,
                                        side: const BorderSide(color: Color(0xFF3C3350)),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: const Text('Reset'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _setCellValue(0),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFFB38BFF),
                                        side: const BorderSide(color: Color(0xFF3C3350)),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: const Text('Clear'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _HomeCard(
                          title: 'Chat',
                          subtitle: 'Solve together, share tactics',
                          icon: Icons.chat_bubble_outline_rounded,
                          accent: const Color(0xFFB38BFF),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SudokuKey extends StatelessWidget {
  const _SudokuKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1624),
          foregroundColor: const Color(0xFFEAE6FF),
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF2C2640)),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF14121A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF262030)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 40),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF9A93B3),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Color(0xFF8F88A6),
          ),
        ],
      ),
    );
  }
}
