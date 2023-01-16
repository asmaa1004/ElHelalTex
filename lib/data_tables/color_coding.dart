// ignore_for_file: non_constant_identifier_names

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../api_link.dart';
import '../components/colors.dart';
import '../dll.dart';
import '../main.dart';

class ColorCoding extends StatefulWidget {
  const ColorCoding({Key? key}) : super(key: key);

  @override
  State<ColorCoding> createState() => _ColorCodingState();
}

class _ColorCodingState extends State<ColorCoding> with DLL {
  ListItem? _NewValue_CustomersData;
  List<DropdownMenuItem<ListItem>> NewDropdownMenuItem_CustomersData = [];

  List<dynamic> customersData = [];

  bool isLoading = false;

  bool isOwner = false;

  String currentCustomer = "ALL";

  String date = sharedPref.getString("S_LastUpdate").toString();

  loadCustomers() async {
    try {
      isLoading = true;
      setState(() {});
      var response = await postRequest(
          apiCustomers, {"CusCode": sharedPref.getString("S_CusCode")});

      if (response['status'] == "success") {
        customersData = response["data"];

        for (var element in customersData) {
          NewDropdownMenuItem_CustomersData.add(
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
              "كارتله الالوان",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
        body: isLoading == true
            ? const Center(
          child: CircularProgressIndicator(
            color: kMainColor,
          ),
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
                        value: _NewValue_CustomersData,
                        items: NewDropdownMenuItem_CustomersData,
                        onChanged: (value) async {
                          setState(() {
                            _NewValue_CustomersData = value;
                            if (value != null) {
                              if (value.CusCode != null) {
                                if (value.CusCode != "0") {
                                  currentCustomer = value.CusCode!;
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
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.symmetric(vertical: 6),
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
                              0.089,
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
                        color: kMainColor,
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
            columnName: 'CusName',
            width: MediaQuery.of(context).size.width * 0.4,
            visible: isOwner,
            label: Container(
                padding: const EdgeInsets.all(2),
                alignment: Alignment.center,
                child: const Text('العميل',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.clip,
                    softWrap: true))),
        GridColumn(
            columnName: 'Color',
            width: MediaQuery.of(context).size.width * 0.4,
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
            columnName: "ColorCode",
            width: MediaQuery.of(context).size.width * 0.3,
            label: Container(
                padding: const EdgeInsets.all(2),
                alignment: Alignment.center,
                child: const Text(
                  "كود اللون",
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ))),
        GridColumn(
            columnName: 'colorNo',
            visible: false,
            width: MediaQuery.of(context).size.width * 0.3,
            label: Container(
                padding: const EdgeInsets.all(2),
                alignment: Alignment.center,
                child: const Text(
                  'رقم اللون',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ))),
        GridColumn(
            columnName: 'Cloth',
            width: MediaQuery.of(context).size.width * 0.4,
            label: Container(
                padding: const EdgeInsets.all(2),
                alignment: Alignment.center,
                child: const Text(
                  'الخامه',
                  overflow: TextOverflow.visible,
                  softWrap: true,
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
                  "لا توجد ألوان",
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
    await postRequest(apiColorCoding, {"CusCode": currentCustomer});

    for (var item in response["data"]) {
      Product current = Product(
        cusName: item['CusName'],
        colorName: item['ColorName'],
        colorCode: item['ColorCode'],
        colorNo: item['ColorNo'],
        cloth: item['Cloth'],
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
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.all(4.0),
      ),
      Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.all(4.0),
        child: Text(
          row.getCells()[1].value,
          overflow: TextOverflow.visible,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4.0),
        child: Text(
          row.getCells()[2].value,
          overflow: TextOverflow.visible,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4.0),
        child: Text(
          row.getCells()[3].value.toString(),
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
    ]);
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  void buildDataGridRow() {
    dataGridRows = productList.map<DataGridRow>((dataGridRow) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'CusName', value: dataGridRow.cusName),
        DataGridCell<String>(columnName: 'ColorName', value: dataGridRow.colorName),
        DataGridCell<String>(columnName: 'ColorCode', value: dataGridRow.colorCode),
        DataGridCell<String>(columnName: 'ColorNo', value: dataGridRow.colorNo),
        DataGridCell<String>(columnName: 'Cloth', value: dataGridRow.cloth),
      ]);
    }).toList(growable: false);
  }
}

class Product {
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      cusName: json['cusName'],
      colorName: json['colorName'],
      colorCode: json['colorCode'],
      colorNo: json['colorNo'],
      cloth: json['cloth'],
    );
  }
  Product({
    required this.cusName,
    required this.colorName,
    required this.colorCode,
    required this.colorNo,
    required this.cloth,
  });

  final String cusName;
  final String colorName;
  final String colorCode;
  final String colorNo;
  final String cloth;
}

class ListItem {
  String? CusCode;
  String? CusName;
  ListItem(this.CusCode, this.CusName);
}
