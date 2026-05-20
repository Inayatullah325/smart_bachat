import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:smart_bachat/database_model_class/expense_data_model.dart';
import 'package:smart_bachat/ui/screens/ui/all_expenses_screen/all_expenses_screen.dart';

class SlidableTransactionItem extends StatefulWidget {
  final ExpenseDataModel transaction;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const SlidableTransactionItem({
    super.key,
    required this.transaction,
    required this.index,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<SlidableTransactionItem> createState() =>
      _SlidableTransactionItemState();
}

class _SlidableTransactionItemState extends State<SlidableTransactionItem> {
  double _offset = 0.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 2.w),
      child: Stack(
        children: [
          // Background actions
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue, size: 3.h),
                    onPressed: () {
                      setState(() => _offset = 0.0);
                      widget.onUpdate();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red, size: 3.h),
                    onPressed: () {
                      setState(() => _offset = 0.0);
                      widget.onDelete();
                    },
                  ),
                  SizedBox(width: 2.w),
                ],
              ),
            ),
          ),
          // Foreground content
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _offset += details.delta.dx;
                // Limit the offset
                if (_offset > 0) _offset = 0;
                if (_offset < -100) _offset = -100;
              });
            },
            onHorizontalDragEnd: (details) {
              setState(() {
                if (_offset < -50) {
                  _offset = -100; // Stay open
                } else {
                  _offset = 0; // Snap back
                }
              });
            },
            child: Transform.translate(
              offset: Offset(_offset, 0),
              child: Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                child: ListTile(
                  onTap: () {
                    if (_offset != 0) {
                      setState(() => _offset = 0);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllExpensesScreen(),
                        ),
                      );
                    }
                  },
                  leading: CircleAvatar(
                    backgroundColor: AppColors.getCategoryColor(
                      widget.transaction.name,
                    ),
                    child: Text(
                      '${widget.index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    widget.transaction.name,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getCategoryColor(
                        widget.transaction.name,
                      ),
                    ),
                  ),
                  subtitle: Text(
                    widget.transaction.date,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Text(
                    'Rs ${widget.transaction.expense}',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.color_red,
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
