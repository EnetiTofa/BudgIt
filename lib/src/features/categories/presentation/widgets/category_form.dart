// lib/src/features/categories/presentation/widgets/category_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/categories/presentation/controllers/add_category_controller.dart';
import 'package:budgit/src/features/categories/presentation/widgets/category_wizard_header.dart';
import 'package:budgit/src/features/categories/presentation/widgets/wizard_steps/basics_step_view.dart';
import 'package:budgit/src/features/categories/presentation/widgets/wizard_steps/recurring_step_view.dart';
import 'package:budgit/src/features/categories/presentation/widgets/wizard_steps/wallet_step_view.dart';
import 'package:budgit/src/features/categories/presentation/widgets/wizard_steps/budget_step_view.dart';
import 'package:budgit/src/features/categories/presentation/widgets/wizard_steps/summary_step_view.dart';

class CategoryForm extends ConsumerWidget {
  const CategoryForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addCategoryControllerProvider);
    final controller = ref.read(addCategoryControllerProvider.notifier);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        canPop: state.step == AddCategoryStep.basics && !state.isLoading,
        onPopInvoked: (didPop) {
          if (!didPop) {
            FocusScope.of(context).unfocus();
            controller.previousStep();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const CategoryWizardHeader(),
              Expanded(
                child: PageView(
                  controller: state.pageController,
                  onPageChanged: controller.onPageChanged,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    BasicsStepView(),
                    RecurringStepView(),
                    WalletStepView(),
                    BudgetStepView(),
                    SummaryStepView(),
                  ],
                ),
              ),
              _NavigationControls(
                currentStep: state.step,
                onBackPressed: () {
                  controller.previousStep();
                },
                onNextPressed: () {
                  // If it's the last step, call saveAndFinish.
                  if (state.step == AddCategoryStep.summary) {
                    controller.saveAndFinish().then((_) {
                      // After saving is complete, close the wizard screen.
                      Navigator.of(context).pop();
                    });
                  } else {
                    controller.nextStep();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationControls extends ConsumerWidget {
  const _NavigationControls({
    required this.currentStep,
    required this.onBackPressed,
    required this.onNextPressed,
  });

  final AddCategoryStep currentStep;
  final VoidCallback onBackPressed;
  final VoidCallback onNextPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFirstStep = currentStep == AddCategoryStep.basics;
    final isLastStep = currentStep == AddCategoryStep.summary;
    // Watch the loading state to update the button
    final isLoading = ref.watch(addCategoryControllerProvider.select((s) => s.isLoading));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          if (!isFirstStep)
            TextButton(
              // Disable the back button while loading
              onPressed: isLoading ? null : onBackPressed,
              child: const Text('Back'),
            ),
          const Spacer(),
          ElevatedButton(
            // Disable the button while loading
            onPressed: isLoading ? null : onNextPressed,
            child: isLoading && isLastStep
                // Show a loading indicator on the finish button
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : Text(isLastStep ? 'Finish' : 'Next'),
          ),
        ],
      ),
    );
  }
}