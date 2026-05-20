import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyBottomSheetProvider with ChangeNotifier {
  TextEditingController incomeDateController = TextEditingController();
  TextEditingController addIncomeController = TextEditingController();

  // these variable have used to get date from the calender
  DateTime? incomeDatePicked;
  DateTime? expenseDatePicked;

  // date variable to be store in db
  String? date;

  createIncomeBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width * 1,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                'Add Budget',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              // date
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                child: TextField(
                  readOnly: true,
                  onTap: () async {
                    incomeDatePicked = await showDatePicker(
                      barrierDismissible: false,
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2099),
                    );

                    if (incomeDatePicked != null) {
                      date =
                          '${incomeDatePicked?.day}-${incomeDatePicked?.month}-${incomeDatePicked?.year}';

                      Fluttertoast.showToast(
                        msg: '$date',
                        // msg: 'date selected: ${incomeDatePicked?.day}-${incomeDatePicked?.month}-${incomeDatePicked?.year}',
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  keyboardType: TextInputType.number,
                  controller: incomeDateController..text = '${date}',
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Select Date',
                    prefixIcon: Icon(
                      Icons.date_range_outlined,
                      color: Colors.blue,
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.lightBlueAccent),
                    ),
                  ),
                ),
              ),

              // textfield
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                child: TextField(
                  onTap: () {},
                  keyboardType: TextInputType.number,
                  controller: addIncomeController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter income here',
                    prefixIcon: Icon(
                      Icons.arrow_circle_down_rounded,
                      color: Colors.blue,
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.lightBlueAccent),
                    ),
                  ),
                ),
              ),

              // add income button
              InkWell(
                onTap: () async {
                  // getting text from text fields into a variable in text form
                  var incomeText = addIncomeController.text;

                  // converting text to integer form to store it in db
                  var income = int.tryParse(incomeText);

                  try {} catch (e) {
                    debugPrint(e.toString());
                  }

                  Fluttertoast.showToast(
                    msg: 'Income added to the wallet',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.06,
                    //  width: MediaQuery.of(context).size.width*0.3,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Add Income',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  createExpensesBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width * 1,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Add Expense',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              // date
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                child: TextField(
                  readOnly: true,
                  onTap: () async {
                    expenseDatePicked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2099),
                    );

                    if (expenseDatePicked != null) {
                      Fluttertoast.showToast(
                        msg:
                            'date selected: ${expenseDatePicked?.day}-${expenseDatePicked?.month}-${expenseDatePicked?.year}',
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Select Date',
                    prefixIcon: Icon(
                      Icons.date_range_outlined,
                      color: Colors.blue,
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.lightBlueAccent),
                    ),
                  ),
                ),
              ),

              // textfield
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                child: TextField(
                  onTap: () {},
                  keyboardType: TextInputType.number,
                  //controller: addExpensesController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter income here',
                    prefixIcon: Icon(
                      Icons.arrow_circle_down_rounded,
                      color: Colors.blue,
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.lightBlueAccent),
                    ),
                  ),
                ),
              ),

              // add expense button
              InkWell(
                onTap: () {
                  Fluttertoast.showToast(
                    msg: "this module will be complete v.soon",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.blue,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.06,
                    //  width: MediaQuery.of(context).size.width*0.3,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Add Expense',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  createCategoryBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width * 1,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Add Budget',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              // textfield
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                child: TextField(
                  onTap: () {},
                  keyboardType: TextInputType.number,
                  controller: addIncomeController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your budget for this category here',
                    prefixIcon: Icon(
                      Icons.monetization_on_outlined,
                      color: Colors.blue,
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.lightBlueAccent),
                    ),
                  ),
                ),
              ),

              // add income button
              InkWell(
                onTap: () {
                  Fluttertoast.showToast(
                    msg: "This module will be complete soon!",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.blue,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.06,
                    //  width: MediaQuery.of(context).size.width*0.3,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Add Budget',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
