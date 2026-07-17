import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_provider.dart';

/// Flujo de bienvenida — 3 pantallas explicando qué hace ErgoFit
/// + 1 pantalla final para configurar nombre y rol laboral.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  final _nameController = TextEditingController();
  String? _selectedRole;
  bool _saving = false;

  static const _slides = [
    _SlideData(
      emoji: '🧘',
      title: 'Pausas activas\nguiadas',
      description:
          'Más de 12 ejercicios de estiramiento diseñados para desarrolladores, diseñadores y oficinistas.',
    ),
    _SlideData(
      emoji: '🤖',
      title: 'IA que corrige\ntu postura',
      description:
          'Activa la cámara y recibe feedback en tiempo real sobre cómo ejecutar cada ejercicio correctamente.',
    ),
    _SlideData(
      emoji: '⏰',
      title: 'Recordatorios\nautomáticos',
      description:
          'Configura alarmas personalizadas que te avisan cuándo tomar una pausa según tu ritmo de trabajo.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    if (_nameController.text.trim().isEmpty || _selectedRole == null) return;
    if (_saving) return;
    setState(() => _saving = true);

    final dao = ref.read(userProfileDaoProvider);
    await dao.updateName(_nameController.text.trim());
    await dao.updateJobRole(_selectedRole!);
    await dao.completeOnboarding();

    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = _slides.length + 1;

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: List.generate(totalPages, (i) {
                  final isActive = i == _currentPage;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: isActive || i < _currentPage
                            ? AppTheme.primary
                            : AppTheme.bgTertiary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  ..._slides.map((s) => _SlideView(data: s)),
                  _ProfileSetupView(
                    nameController: _nameController,
                    selectedRole: _selectedRole,
                    onRoleSelected: (role) =>
                        setState(() => _selectedRole = role),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _currentPage < _slides.length
                      ? _nextPage
                      : (_nameController.text.trim().isNotEmpty &&
                              _selectedRole != null &&
                              !_saving)
                          ? _finishOnboarding
                          : null,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _currentPage < _slides.length
                              ? 'Continuar'
                              : 'Comenzar',
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideData {
  final String emoji;
  final String title;
  final String description;
  const _SlideData({
    required this.emoji,
    required this.title,
    required this.description,
  });
}

class _SlideView extends StatelessWidget {
  final _SlideData data;
  const _SlideView({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(data.emoji, style: const TextStyle(fontSize: 64)),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSetupView extends StatelessWidget {
  final TextEditingController nameController;
  final String? selectedRole;
  final ValueChanged<String> onRoleSelected;

  const _ProfileSetupView({
    required this.nameController,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            '¿Cómo te llamas?',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Usaremos tu nombre para personalizar la experiencia',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            autofocus: false,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
            decoration: const InputDecoration(
              hintText: 'Tu nombre',
              prefixIcon: Icon(Icons.person_outline_rounded,
                  color: AppTheme.textHint),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            '¿Cuál es tu rol laboral?',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Para sugerirte ejercicios relevantes',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppConstants.roleLabels.entries.map((entry) {
              final isSelected = selectedRole == entry.key;
              return GestureDetector(
                onTap: () => onRoleSelected(entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.bgSecondary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.border,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}