// ignore_for_file: non_constant_identifier_names

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../api_link.dart';
import '../components/colors.dart';
import '../dll.dart';
import '../main.dart';

class UnderProcess extends StatefulWidget {
  const UnderProcess({Key? key}) : super(key: key);

  @override
  State<UnderProcess> createState() => _UnderProcessState();
}

class _UnderProcessState extends State<UnderProcess> with DLL {
  ListItem? _newValue_CustomersData;
  List<DropdownMenuItem<ListItem>> newDropdownMenuItem_CustomersData = [];

  List<dynamic> customersData = [];

  bool isLoading = false;

  bool isOwner = false;

  String currentCustomer = "ALL";

  loadCustomers() async {
    try {
      isLoading = true;
      setState(() {});
      var response = await postRequest(
          apiCustomers, {"CusCode": sharedPref.getString("S_CusCode")});

      if (response['status'] == "success") {
        customersData = response["data"];

        for (var element in customersData) {
          newDropdownMenuItem_CustomersData.add(
            DropdownMenuItem(
              child: Text(element["CusName"]),
              value: ListItem(
                element["CusCode"],
                element["CusName"],
              ),
            ),
          );
        }

        isLoading = false;
        setState(() {});
      } else {
        AwesomeDialog(
                context: context,
                showCloseIcon: true,
                title: "Alert",
                body: const Text("Can't Load Data"))
            .show();
      }
    } catch (e) {
      AwesomeDialog(
              context: context,
              showCloseIcon: true,
              title: "Alert",
              body: Text(e.toString()))
          .show();
    }
  }

  @override
  void initState() {
    super.initState();
    if (sharedPref.getString("S_UserType") == '0') {
      currentCustomer = sharedPref.getString("S_CusCode")!;
    } else {
      loadCustomers();
      isOwner = true;
      currentCustomer = "";
    }
  }

  final items = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 10.0,
          backgroundColor: kMainColor,
          actions: [
            Container(
              padding: const EdgeInsets.all(5),
              child: Image.asset(
                'assets/images/Logo.png',
                width: 50,
              ),
            ),
          ],
          title: const Center(
            child: Text(
              "تحت التشغيل",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
        body: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Visibility(
                      visible: isOwner,
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                          color: kMainColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ListItem>(
                              isExpanded: true,
                              hint: const Text(
                                "اختر العميل",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                ),
                              ),
                              value: _newValue_CustomersData,
                              items: newDropdownMenuItem_CustomersData,
                              onChanged: (value) async {
                                setState(() {
                                  _newValue_CustomersData = value;
                                  if (value != null) {
                                    if (value.cusCode != null) {
                                      if (value.cusCode != "0") {
                                        currentCustomer = value.cusCode!;
                                      } else {
                                        currentCustomer = "ALL";
                                      }
                                      loadCustomers();
                                    }
                                  }
                                });
                              }),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          sharedPref.getString("S_LastUpdate").toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.78,
                      child: FutureBuilder(
                        future: getProductDataSource(),
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          return snapshot.hasData
                              ? SfDataGridTheme(
                                  data: SfDataGridThemeData(
                                    headerColor: kMainColor.withOpacity(0.7),
                                  ),
                                  child: SfDataGrid(
                                      source: snapshot.data,
                                      columns: getColumns(snapshot),
                                      allowPullToRefresh: true,
                                      allowSorting: true,
                                      rowHeight:
                                          MediaQuery.of(context).size.height *
                                              0.08,
                                      selectionMode: SelectionMode.multiple,
                                      gridLinesVisibility:
                                          GridLinesVisibility.both,
                                      headerGridLinesVisibility:
                                          GridLinesVisibility.both,
                                      ),
                                )
                              : const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 4,
                                  ),
                                );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<ProductDataGridSource> getProductDataSource() async {
    var productList = await generateProductList();
    return ProductDataGridSource(productList);
  }

  List<GridColumn> getColumns( AsyncSnapshot<dynamic> snapshot ) {

    ProductDataGridSource dataSource = snapshot.data ;

    if (dataSource.productList.isNotEmpty ){
      return <GridColumn>[
        GridColumn(
            columnName: 'CusSNo',
            width: MediaQuery.of(context).size.width * 0.23,
            label: Container(
                padding: const EdgeInsets.all(2),
                alignment: Alignment.center,
                child: const Text('الرساله',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.clip,
                    softWrap: true))),
        GridColumn(
            columnName: 'SerialNo',
            width: MediaQuery.of(context).size.width * 0.25,
            label: Container(
                padding: const EdgeInsets.all(2),
                alignment: Alignment.center,
                child: const Text(
                  'امر الشغل',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ))),
        GridColumn(
            columnName: "CusName",
            width: MediaQuery.of(context).size.width * 0.6,
            visible: isOwner,
            label: Container(
                padding: const EdgeInsets.all(2),
                alignment: Alignment.center,
                child: const Text(
                  "العميل",
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ))),
        GridColumn(
            columnName: "Cloth",
            width: MediaQuery.of(context).size.width * 0.5,
            label: Container(
                padding: const EdgeInsets.all(2),
                alignment: Alignment.center,
                child: const Text(
                  "الخام",
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ))),
        GridColumn(
            columnName: 'ThNo',
            width: MediaQuery.of(context).size.width * 0.2,
            label: Container(
                padding: const EdgeInsets.all(2),
                alignment: Alignment.center,
                child: const Text(
                  'الغزل',
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ))),
        GridColumn(
            columnName: 'Color',
            width: MediaQuery.of(context).size.width * 0.35,
            label: Container(
                padding: const EdgeInsets.all(2),
                alignment: Alignment.center,
                child: const Text(
                  'اللون',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ))),
        GridColumn(
            columnName: 'ColorCode',
            width: MediaQuery.of(context).size.width * 0.2,
            label: Container(
                padding: const EdgeInsets.all(2),
                alignment: Alignment.center,
                child: const Text('الكود',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.clip,
                    softWrap: true))),
        GridColumn(
            columnName: "RawWt",
            width: MediaQuery.of(context).size.width * 0.25,
            label: Container(
                padding: const EdgeInsets.all(2),
                alignment: Alignment.center,
                child: const Text(
                  "وزن الخام",
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ))),
        GridColumn(
            columnName: 'finRawWt',
            width: MediaQuery.of(context).size.width * 0.3,
            label: Container(
                padding: const EdgeInsets.all(2),
                alignment: Alignment.center,
                child: const Text(
                  'رصيد الجاهز',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ))),
      ];
    }
    else{
      return<GridColumn>[
        GridColumn(
            columnName: '',
            width: MediaQuery.of(context).size.width + 4 ,
            label: Container(
                padding: const EdgeInsets.only(top: 10),
                alignment: Alignment.center,
                color: Colors.white,
                child: const Text(
                  "لا يوجد خام تحت التشغيل",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: kMainColor,
                  ),
                ))),
      ] ;
    }
  }

  Future<List<Product>> generateProductList() async {
    List<Product> productList = [];
    var response =
        await postRequest(apiUnderProcess, {"CusCode": currentCustomer});

    for (var item in response["data"]) {
      Product current = Product(
        cusSNo: item['CusSNo'] ?? "",
        serialNo: item['SerialNo'] ?? "",
        cusName: item['CusName'] ?? "",
        cloth: item['Cloth'] ?? "",
        thNo: item['ThNo'] ?? "",
        color: item['Color'] ?? "",
        colorCode: item['ColorCode'] ?? "",
        rawWt: item['RawWt'] ?? "",
        finRawWt: item['FinRawWt'] ?? "",
      );

      productList.add(current);
    }
    return productList;
  }
}

class ProductDataGridSource extends DataGridSource {
  ProductDataGridSource(this.productList) {
    buildDataGridRow();
  }
  late List<DataGridRow> dataGridRows;
  late List<Product> productList;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: [
      Container(
        child: Text(
          row.getCells()[0].value,
          overflow: TextOverflow.visible,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4.0),
      ),
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4.0),
        child: Text(
          row.getCells()[1].value,
          overflow: TextOverflow.visible,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.all(4.0),
        child: Text(
          row.getCells()[2].value,
          overflow: TextOverflow.visible,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.all(4.0),
        child: Text(
          row.getCells()[3].value,
          overflow: TextOverflow.visible,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4.0),
          child: Text(
            row.getCells()[4].value,
            overflow: TextOverflow.visible,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          )),
      Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.all(4.0),
          child: Text(
            row.getCells()[5].value,
            overflow: TextOverflow.visible,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          )),
      Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4.0),
          child: Text(
            row.getCells()[6].value,
            overflow: TextOverflow.visible,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          )),
      Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4.0),
          child: Text(
            row.getCells()[7].value,
            overflow: TextOverflow.visible,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          )),
      Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4.0),
          child: Text(
            row.getCells()[8].value,
            overflow: TextOverflow.visible,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          )),
    ]);
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  void buildDataGridRow() {
    dataGridRows = productList.map<DataGridRow>((dataGridRow) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'CusSNo', value: dataGridRow.cusSNo),
        DataGridCell<String>(columnName: 'SerialNo', value: dataGridRow.serialNo),
        DataGridCell<String>(columnName: 'CusName', value: dataGridRow.cusName),
        DataGridCell<String>(columnName: 'Cloth', value: dataGridRow.cloth),
        DataGridCell<String>(columnName: 'ThNo', value: dataGridRow.thNo),
        DataGridCell<String>(columnName: 'Color', value: dataGridRow.color),
        DataGridCell<String>(columnName: 'ColorCode', value: dataGridRow.colorCode),
        DataGridCell<String>(columnName: 'RawWt', value: dataGridRow.rawWt),
        DataGridCell<String>(columnName: 'FinRawWt', value: dataGridRow.finRawWt),
      ]);
    }).toList(growable: false);
  }
}

class Product {
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        cusSNo: json["CusSNo"],
        serialNo: json["SerialNo"],
        cusName:json["CusName"],
        cloth: json["Cloth"],
        thNo: json["ThNo"],
        color: json["Color"],
        colorCode: json["ColorCode"],
        rawWt: json["RawWt"],
        finRawWt: json["FinRawWt"] ,
    );
  }
  Product({
    required this.cusSNo,
    required this.serialNo,
    required this.cusName,
    required this.cloth,
    required this.thNo,
    required this.color,
    required this.colorCode,
    required this.rawWt,
    required this.finRawWt,
  });

  final String cusSNo;
  final String serialNo;
  final String cusName;
  final String cloth;
  final String thNo;
  final String color;
  final String colorCode;
  final String rawWt;
  final String finRawWt;
}

class ListItem {
  String? cusCode;
  String? cusName;
  ListItem(this.cusCode, this.cusName);
}
