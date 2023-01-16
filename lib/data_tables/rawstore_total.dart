// ignore_for_file: non_constant_identifier_names

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../api_link.dart';
import '../components/colors.dart';
import '../dll.dart';
import '../main.dart';



class RawStoreTotal extends StatefulWidget {
  const RawStoreTotal({Key? key}) : super(key: key);

  @override
  State<RawStoreTotal> createState() => _RawStoreTotalState();
}

class _RawStoreTotalState extends State<RawStoreTotal> with DLL {

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
              "رصيد الخام مجمع",
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
                        selectionColor: Colors.grey,
                      ),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
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
            columnName: 'Cloth',
            width: MediaQuery.of(context).size.width * 0.45,
            label: Container(
                padding: const EdgeInsets.all(2),
                alignment: Alignment.center,
                child: const Text(
                  'الخام',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ))),
        GridColumn(
            columnName: 'CusName',
            width: MediaQuery.of(context).size.width * 0.45,
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
            columnName: "SRI",
            width: MediaQuery.of(context).size.width * 0.3,
            label: Container(
                padding: const EdgeInsets.all(2),
                alignment: Alignment.center,
                child: const Text(
                  "أثواب وارده",
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ))),
        GridColumn(
            columnName: 'SRWI',
            width: MediaQuery.of(context).size.width * 0.2,
            label: Container(
                padding: const EdgeInsets.all(2),
                alignment: Alignment.center,
                child: const Text(
                  'خام وارد',
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ))),
        GridColumn(
            columnName: 'SRW',
            width: MediaQuery.of(context).size.width * 0.2,
            label: Container(
                padding: const EdgeInsets.all(2),
                alignment: Alignment.center,
                child: const Text(
                  'الرصيد',
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
                  "لا يوجد رصيد",
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
    await postRequest(apiRawstoreTotal, {"CusCode": currentCustomer});

    for (var item in response["data"]) {
      Product current = Product(
          cloth:  item['Cloth'] ?? "" ,
          cusName: item['CusName'] ?? "",
          sri: item['SRI'] ?? "",
          srwi: item['SRWI'] ?? "",
          srw: item['SRW'] ?? "",
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
        padding: const EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[2].value,
          overflow: TextOverflow.visible,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.all(8.0),
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
    ]);
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  void buildDataGridRow() {
    dataGridRows = productList.map<DataGridRow>((dataGridRow) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'Cloth', value: dataGridRow.cloth),
        DataGridCell<String>(columnName: 'CusName', value: dataGridRow.cusName),
        DataGridCell<String>(columnName: 'SRI', value: dataGridRow.sri),
        DataGridCell<String>(columnName: 'SRWI', value: dataGridRow.srwi),
        DataGridCell<String>(columnName: 'SRW', value: dataGridRow.srw),
      ]);
    }).toList(growable: false);
  }
}

class Product {
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      cloth: json["Cloth"],
      cusName: json["CusName"],
      sri: json["SRI"],
      srwi: json["SRWI"],
      srw: json["SRW"],);
  }
  Product({
    required this.cloth,
    required this.cusName,
    required this.sri,
    required this.srwi,
    required this.srw,
  });

  final String cloth;
  final String cusName;
  final String sri;
  final String srwi;
  final String srw;
}

class ListItem {
  String? cusCode;
  String? cusName;
  ListItem(this.cusCode, this.cusName);
}
