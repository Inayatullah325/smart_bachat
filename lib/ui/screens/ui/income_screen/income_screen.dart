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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: Text(
          'All Income',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: provider.incomes.isEmpty
          ? Center(
              child: Text(
                'No income records yet.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
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
                      message: 'Do you really want to delete this income?',
                      onConfirm: () async {
                        await Provider.of<TransactionProvider>(
                          context,
                          listen: false,
                        ).deleteIncome(item.id!);
                        Fluttertoast.showToast(
                          msg: 'Income Deleted',
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
                      successMessage: 'Income updated successfully',
                    );
                  },
                );
              },
            ),
    );
  }
}
