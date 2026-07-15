import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:smart_bachat/database_model_class/income_data_model.dart';
import 'package:smart_bachat/providers/transaction_provider.dart';
import 'package:smart_bachat/ui/components/grouped_transaction_list.dart';
import 'package:smart_bachat/ui/components/transaction_item.dart';
import 'package:smart_bachat/ui/components/dialogs/confirmation_dialog.dart';
import 'package:smart_bachat/ui/components/dialogs/update_income_dialog.dart';
import 'package:smart_bachat/l10n/app_localizations.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).fetchAllIncomes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: Text(
          l10n.allIncomeTitle,
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: provider.isLoadingIncomes
          ? Center(
              child: CircleAvatar(
                radius: 35,
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
                child: const SizedBox(
                  width: 35,
                  height: 35,
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                    strokeWidth: 3,
                  ),
                ),
              ),
            )
          : provider.incomes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColors.primaryColor,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noIncomeRecords,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : GroupedTransactionList<IncomeDataModel>(
              items: provider.incomes,
              getDate: (item) => item.date ?? '',
              getAmount: (item) => item.income ?? 0,
              itemBuilder: (context, item, index) {
                return SlidableIncomeItem(
                  transaction: item,
                  index: index,
                  onTap: () {},
                  onDelete: () {
                    showConfirmationDialog(
                      context: context,
                      message: l10n.deleteIncomeConfirm,
                      onConfirm: () async {
                        await Provider.of<TransactionProvider>(
                          context,
                          listen: false,
                        ).deleteIncome(item.id!);
                        Fluttertoast.showToast(
                          msg: l10n.incomeDeleted,
                          backgroundColor: Colors.redAccent,
                        );
                      },
                    );
                  },
                  onUpdate: () {
                    showUpdateIncomeDialog(
                      context: context,
                      id: item.id!,
                      date: item.date.toString(),
                      income: item.income ?? 0,
                      onUpdate: (id, model) async {
                        await Provider.of<TransactionProvider>(
                          context,
                          listen: false,
                        ).updateIncome(id, model);
                      },
                      successMessage: l10n.updatedSuccessfully,
                    );
                  },
                );
              },
            ),
    );
  }
}
