import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/components/add_item_dialog.dart';
import 'package:frontend/components/adjust_transaction_dialog.dart';
import 'package:frontend/components/close_inventory_dialog.dart';
import 'package:frontend/components/portal_card.dart';
import 'package:frontend/components/show_inventory_item_dialog.dart';
import 'package:frontend/screens/audit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../components/item_card.dart';
import '../components/remove_item_dialog.dart';
import '../constants.dart';
import 'package:http/http.dart' as http;

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key, required this.stateData});

  final Map<String, dynamic> stateData;
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late String storeImage;
  late DateTime selectedDate;
  late String date;
  late DateTime now;

  late TabController tabController;
  int tabIndex = 0;
  bool allowAdjustTransaction = false;
  bool allowAddRemoveTransaction = false;

  List<Map<String, dynamic>>? inventoryItemsOpening;
  List<Map<String, dynamic>> inventoryItemsClosing = [];
  List<Map<String, dynamic>>? inventoryTransactions;
  List<Map<String, dynamic>>? inventoryItemsRunning;
  List<Map<String, dynamic>>? inventoryItemsAdding;
  List<Map<String, dynamic>>? inventoryItemsRemoving;

  void fetchData() async {
    Map<String, dynamic> response = await getInventoryOpening(
        widget.stateData["branch"]["id"],
        DateFormat('MM/dd/yyyy HH:mm:ss').format(selectedDate));
    if (response["status"] == 200) {
      inventoryItemsOpening =
          List<Map<String, dynamic>>.from(response["items"]);
    } else if (response["status"] == 404) {
      inventoryItemsOpening = [];
    }

    response = await getInventoryClosing(widget.stateData["branch"]["id"],
        DateFormat('MM/dd/yyyy HH:mm:ss').format(selectedDate));
    if (response["status"] == 200) {
      inventoryItemsClosing =
          List<Map<String, dynamic>>.from(response["items"]);
    } else if (response["status"] == 404) {
      inventoryItemsClosing = [];
    }

    response = await getInventoryTransactions(widget.stateData["branch"]["id"],
        DateFormat('MM/dd/yyyy HH:mm:ss').format(selectedDate));
    if (response["status"] == 200) {
      inventoryTransactions =
          List<Map<String, dynamic>>.from(response["transactions"]);
    } else if (response["status"] == 404) {
      inventoryTransactions = [];
    }

    response = await getIngredients(widget.stateData["branch"]["id"]);
    if (response["status"] == 200) {
      inventoryItemsAdding =
          List<Map<String, dynamic>>.from(response["ingredients"]);
    } else if (response["status"] == 404) {
      inventoryItemsAdding = [];
    }

    allowAddRemoveTransaction = inventoryItemsAdding!.isNotEmpty &&
        [1, 3].contains(widget.stateData["user"]["user_type"]) &&
        (selectedDate.month == now.month &&
            selectedDate.day == now.day &&
            selectedDate.year == now.year) &&
        inventoryItemsClosing.isEmpty;

    allowAdjustTransaction = inventoryItemsAdding!.isNotEmpty &&
        [1, 2].contains(widget.stateData["user"]["user_type"]) &&
        (selectedDate.month == now.month &&
            selectedDate.day == now.day &&
            selectedDate.year == now.year) &&
        inventoryItemsClosing.isEmpty;

    inventoryItemsRunning =
        computeRunningInventory(inventoryItemsOpening!, inventoryTransactions!);
    inventoryItemsRemoving =
        getInventoryItemsRemoving(inventoryItemsRunning, inventoryItemsAdding);
    if (!mounted) return;
    setState(() {});
  }

  List<Map<String, dynamic>>? getInventoryItemsRemoving(
      List<Map<String, dynamic>>? itemsRunning,
      List<Map<String, dynamic>>? itemsAdding) {
    if (itemsRunning == null || itemsAdding == null) return null;

    List addingIds = itemsAdding.map((item) => item['id']).toList();

    List<Map<String, dynamic>>? inventoryItemsRemoving = itemsRunning
        .where((item) => addingIds.contains(item['ingredient_id']))
        .toList();

    return inventoryItemsRemoving;
  }

  String formatTimeString(String dateString) {
    DateTime dateTime = DateFormat('E, d MMM y H:m:s z').parse(dateString);
    return DateFormat('h:mm:ss a').format(dateTime);
  }

  List<Map<String, dynamic>> computeRunningInventory(
      List<Map<String, dynamic>> opening,
      List<Map<String, dynamic>> transactions) {
    Map<int, Map<String, dynamic>> ingredientDetails = {};

    // Initialize ingredient details with opening values
    for (var item in opening) {
      int ingredientId = item['ingredient_id'];
      ingredientDetails[ingredientId] = {
        'name': item['name'],
        'quantity': item['quantity'],
        'unit': item['unit'],
        'tolerance': item['tolerance']
      };
    }

    // Process transactions
    for (var transaction in transactions) {
      int ingredientId = transaction['details']['ingredient_id'];
      double quantityChange = transaction['details']['quantity'];

      if (ingredientDetails.containsKey(ingredientId)) {
        ingredientDetails[ingredientId]!['quantity'] += quantityChange;
      } else {
        ingredientDetails[ingredientId] = {
          'name': transaction['ingredient']['name'],
          'quantity': quantityChange,
          'unit': transaction['ingredient']['unit'],
          'tolerance': transaction['ingredient']['tolerance']
        };
      }
    }

    // Generate the running inventory
    List<Map<String, dynamic>> runningInventory = [];
    ingredientDetails.forEach((ingredientId, details) {
      runningInventory.add({
        'ingredient_id': ingredientId,
        'name': details['name'],
        'quantity': details['quantity'],
        'unit': details['unit'],
        'tolerance': details['tolerance']
      });
    });

    return runningInventory;
  }

  @override
  void initState() {
    now = DateTime.now();

    if (widget.stateData["branch"]["name"]
        .toString()
        .toLowerCase()
        .contains("ayame")) {
      storeImage = "assets/ayame-logo-small.png";
    } else {
      storeImage = "assets/myjoy-logo-small.png";
    }
    selectedDate = DateTime.now();
    date = DateFormat('MMMM d, y').format(selectedDate);
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      setState(() {
        tabIndex = tabController.index;
      });
    });
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 40),
            color: primaryColor,
            child: Align(
                alignment: Alignment.bottomCenter,
                child: PortalCard(portalName: "inventory & audit")),
          ),
          Container(
            height: size.height - 150,
            padding: const EdgeInsets.only(left: 30, right: 30, top: 50),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            image:
                                DecorationImage(image: AssetImage(storeImage)),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.stateData["branch"]["name"],
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.stateData["user"]["fullname"],
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14,
                                  color: grayText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    [1, 2].contains(widget.stateData["user"]["user_type"])
                        ? GestureDetector(
                            onTap: [
                              1,
                              2
                            ].contains(widget.stateData["user"]["user_type"])
                                ? () async {
                                    if (inventoryItemsClosing.isEmpty &&
                                        inventoryItemsRunning != null &&
                                        inventoryItemsRunning!.isNotEmpty &&
                                        (selectedDate.month == now.month &&
                                            selectedDate.day == now.day &&
                                            selectedDate.year == now.year)) {
                                      Map<String, dynamic> stateData = {
                                        "auth_token":
                                            widget.stateData["auth_token"],
                                        "date": selectedDate,
                                        "branch_id": widget.stateData["branch"]
                                            ["id"]
                                      };
                                      final res = await showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CloseInventoryDialog(
                                            stateData: stateData,
                                            inventoryItems:
                                                inventoryItemsRunning!,
                                          ); // Use the custom dialog widget
                                        },
                                      );
                                      if (res != null && res == true) {
                                        fetchData();
                                      }
                                    } else if (inventoryItemsClosing
                                        .isNotEmpty) {
                                      Map<String, dynamic> stateData =
                                          widget.stateData;
                                      stateData["date"] =
                                          DateFormat('MM/dd/yyyy HH:mm:ss')
                                              .format(selectedDate);
                                      stateData["date_string"] =
                                          DateFormat('MMMM d, y')
                                              .format(selectedDate);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute<void>(
                                          builder: (BuildContext context) =>
                                              AuditScreen(
                                                  stateData: stateData,
                                                  inventoryItemsClosing:
                                                      inventoryItemsClosing,
                                                  inventoryItemsRunning:
                                                      inventoryItemsRunning ??
                                                          []),
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: (selectedDate.month == now.month &&
                                        selectedDate.day == now.day &&
                                        selectedDate.year == now.year)
                                    ? inventoryItemsRunning != null &&
                                            inventoryItemsRunning!.isNotEmpty
                                        ? primaryColor
                                        : grayColor
                                    : inventoryItemsClosing.isEmpty
                                        ? grayColor
                                        : primaryColor,
                              ),
                              child: Center(
                                child: Text(
                                  inventoryItemsClosing.isEmpty &&
                                          inventoryItemsRunning != null &&
                                          inventoryItemsRunning!.isNotEmpty
                                      ? 'Close Inventory'
                                      : 'Generate Audit',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                    Row(
                      children: [
                        Text(
                          date,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.calendar_today,
                            color: primaryColor,
                          ),
                          onPressed: () => _selectDate(context),
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        TabBar(
                          controller: tabController,
                          indicatorColor: primaryColor,
                          indicatorWeight: 5,
                          labelColor: Colors.black,
                          labelStyle: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                          tabs: [
                            const Tab(text: 'Opening'),
                            const Tab(text: 'Transactions'),
                            Tab(
                                text: inventoryItemsClosing.isEmpty
                                    ? 'Running'
                                    : 'Closing'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: tabController,
                            children: [
                              inventoryItemsOpening == null
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : inventoryItemsOpening!.isEmpty
                                      ? Center(
                                          child: Text(
                                            "No items for this date yet.",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14,
                                              color: grayText,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount:
                                              inventoryItemsOpening!.length,
                                          itemBuilder: (context, index) {
                                            Map<String, dynamic> item =
                                                inventoryItemsOpening![index];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  bottom: 10.0),
                                              child: ItemCard(
                                                  item: item,
                                                  refreshCallback: fetchData),
                                            );
                                          },
                                        ),
                              inventoryTransactions == null
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : inventoryTransactions!.isEmpty
                                      ? Center(
                                          child: Text(
                                            "No transactions for this date yet.",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14,
                                              color: grayText,
                                            ),
                                          ),
                                        )
                                      : Align(
                                          alignment: Alignment.topCenter,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 50.0, top: 10),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        border: Border(
                                                          right: BorderSide(
                                                              color: grayColor,
                                                              width: 1),
                                                        ),
                                                      ),
                                                      child: DataTable(
                                                        columns: [
                                                          DataColumn(
                                                            label: Text(
                                                              'Item',
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                        rows:
                                                            inventoryTransactions!
                                                                .map((row) {
                                                          return DataRow(
                                                            cells: [
                                                              DataCell(Text(
                                                                row['ingredient']
                                                                    ['name'],
                                                                style: GoogleFonts
                                                                    .montserrat(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 14,
                                                                ),
                                                              )),
                                                            ],
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child:
                                                        SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: DataTable(
                                                          columns: [
                                                            DataColumn(
                                                              label: Text(
                                                                'Type',
                                                                style: GoogleFonts
                                                                    .montserrat(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: Text(
                                                                'Quantity',
                                                                style: GoogleFonts
                                                                    .montserrat(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: Text(
                                                                'Timestamp',
                                                                style: GoogleFonts
                                                                    .montserrat(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: Text(
                                                                'Remarks',
                                                                style: GoogleFonts
                                                                    .montserrat(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: Text(
                                                                'Done By',
                                                                style: GoogleFonts
                                                                    .montserrat(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                          rows:
                                                              inventoryTransactions!
                                                                  .map((row) {
                                                            return DataRow(
                                                                cells: [
                                                                  DataCell(Text(
                                                                    row['details']
                                                                        [
                                                                        'transaction_type'],
                                                                    style: GoogleFonts
                                                                        .montserrat(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          14,
                                                                      color: row['details']['quantity'] >=
                                                                              0
                                                                          ? primaryColor
                                                                          : errorColor,
                                                                    ),
                                                                  )),
                                                                  DataCell(Text(
                                                                    row['details']
                                                                            [
                                                                            'quantity']
                                                                        .abs()
                                                                        .toString(),
                                                                    style: GoogleFonts
                                                                        .montserrat(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  )),
                                                                  DataCell(Text(
                                                                    formatTimeString(
                                                                      row['details']
                                                                              [
                                                                              'datetime_created']
                                                                          .toString(),
                                                                    ),
                                                                    style: GoogleFonts
                                                                        .montserrat(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  )),
                                                                  DataCell(Text(
                                                                    row['details']
                                                                            [
                                                                            'remarks']
                                                                        .toString(),
                                                                    style: GoogleFonts
                                                                        .montserrat(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  )),
                                                                  DataCell(Text(
                                                                    row['details']
                                                                            [
                                                                            'done_by']
                                                                        .toString(),
                                                                    style: GoogleFonts
                                                                        .montserrat(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  )),
                                                                ]);
                                                          }).toList()),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                              inventoryItemsClosing.isEmpty
                                  ? inventoryItemsRunning == null
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : inventoryItemsRunning!.isEmpty
                                          ? Center(
                                              child: Text(
                                                "No items for this date yet.",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 14,
                                                  color: grayText,
                                                ),
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount:
                                                  inventoryItemsRunning!.length,
                                              itemBuilder: (context, index) {
                                                Map<String, dynamic> item =
                                                    inventoryItemsRunning![
                                                        index];
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          bottom: 10.0),
                                                  child: ItemCard(
                                                      item: item,
                                                      refreshCallback:
                                                          fetchData),
                                                );
                                              },
                                            )
                                  : ListView.builder(
                                      itemCount: inventoryItemsClosing.length,
                                      itemBuilder: (context, index) {
                                        Map<String, dynamic> item =
                                            inventoryItemsClosing[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                              bottom: 10.0),
                                          child: GestureDetector(
                                            onTap: () async {
                                              await showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return ShowInventoryItemDialog(
                                                    inventoryItem: item,
                                                  ); // Use the custom dialog widget
                                                },
                                              );
                                            },
                                            child: ItemCard(
                                                item: item,
                                                refreshCallback: fetchData),
                                          ),
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          [1, 3].contains(widget.stateData["user"]["user_type"])
              ? Positioned(
                  bottom: 125,
                  right: 55,
                  child: GestureDetector(
                    onTap: allowAddRemoveTransaction
                        ? () async {
                            final res = await showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                final stateData = {
                                  "auth_token": widget.stateData["auth_token"],
                                  "date": selectedDate,
                                  "branch_id": widget.stateData["branch"]["id"],
                                  "ingredients": inventoryItemsAdding,
                                  "user_id": widget.stateData["user"]["id"]
                                };
                                return AddItemDialog(
                                  stateData: stateData,
                                ); // Use the custom dialog widget
                              },
                            );
                            if (res != null && res == true) {
                              fetchData();
                            }
                          }
                        : null,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        color: allowAddRemoveTransaction
                            ? primaryColor
                            : grayColor,
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: const Center(
                          child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 40,
                      )),
                    ),
                  ),
                )
              : const SizedBox(),
          [1, 3].contains(widget.stateData["user"]["user_type"])
              ? Positioned(
                  bottom: 125,
                  left: 55,
                  child: GestureDetector(
                    onTap: allowAddRemoveTransaction
                        ? () async {
                            final res = await showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                final stateData = {
                                  "auth_token": widget.stateData["auth_token"],
                                  "date": selectedDate,
                                  "branch_id": widget.stateData["branch"]["id"],
                                  "ingredients": inventoryItemsRemoving,
                                  "user_id": widget.stateData["user"]["id"]
                                };
                                return RemoveItemDialog(
                                  stateData: stateData,
                                ); // Use the custom dialog widget
                              },
                            );
                            if (res != null && res == true) {
                              fetchData();
                            }
                          }
                        : null,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        color: allowAddRemoveTransaction
                            ? primaryColor
                            : grayColor,
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: const Center(
                          child: Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 40,
                      )),
                    ),
                  ),
                )
              : const SizedBox(),
          [1, 2].contains(widget.stateData["user"]["user_type"])
              ? Positioned(
                  bottom: 125,
                  left: MediaQuery.of(context).size.width / 2 - 30,
                  child: GestureDetector(
                    onTap: allowAdjustTransaction
                        ? () async {
                            final res = await showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                final stateData = {
                                  "auth_token": widget.stateData["auth_token"],
                                  "date": selectedDate,
                                  "branch_id": widget.stateData["branch"]["id"],
                                  "ingredients": inventoryItemsRemoving,
                                  "user_id": widget.stateData["user"]["id"]
                                };
                                return AdjustTransactionDialog(
                                  stateData: stateData,
                                ); // Use the custom dialog widget
                              },
                            );
                            if (res != null && res == true) {
                              fetchData();
                            }
                          }
                        : null,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        color:
                            allowAdjustTransaction ? primaryColor : grayColor,
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: const Center(
                          child: Icon(
                        Icons.build,
                        color: Colors.white,
                        size: 20,
                      )),
                    ),
                  ),
                )
              : const SizedBox()
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        date = DateFormat('MMMM d, y').format(selectedDate);
        inventoryItemsOpening = null;
        inventoryTransactions = null;
        inventoryItemsRunning = null;
        inventoryItemsAdding = null;
        inventoryItemsRemoving = null;
      });
      fetchData();
    }
  }

  Future<Map<String, dynamic>> getIngredients(int branchID) async {
    String url = '$baseURL/ingredients?branch_id=$branchID';
    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;
    return responseData;
  }

  Future<Map<String, dynamic>> getInventoryOpening(
      int branchID, String date) async {
    String url = '$baseURL/inventory_starting?date=$date&branch_id=$branchID';
    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;
    return responseData;
  }

  Future<Map<String, dynamic>> getInventoryClosing(
      int branchID, String date) async {
    String url = '$baseURL/inventory_closing?date=$date&branch_id=$branchID';
    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;
    return responseData;
  }

  Future<Map<String, dynamic>> getInventoryTransactions(
      int branchID, String date) async {
    String url =
        '$baseURL/inventory_transaction?date=$date&branch_id=$branchID';
    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;
    return responseData;
  }
}
