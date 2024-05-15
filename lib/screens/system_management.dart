import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/components/add_branch.dart';
import 'package:frontend/components/add_user_dialog.dart';
import 'package:frontend/components/branch_card.dart';
import 'package:frontend/components/edit_branch_dialog.dart';
import 'package:frontend/components/edit_user_dialog.dart';
import 'package:frontend/components/portal_card.dart';
import 'package:frontend/components/user_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class SystemManagementScreen extends StatefulWidget {
  const SystemManagementScreen({super.key, required this.stateData});

  final Map<String, dynamic> stateData;
  @override
  State<SystemManagementScreen> createState() => _SystemManagementScreenState();
}

class _SystemManagementScreenState extends State<SystemManagementScreen>
    with SingleTickerProviderStateMixin {
  late String storeImage;
  late TabController tabController;
  List<Map<String, dynamic>>? users;
  List<Map<String, dynamic>>? branches;

  int tabIndex = 0;

  @override
  void initState() {
    if (widget.stateData["branch"]["name"]
        .toString()
        .toLowerCase()
        .contains("ayame")) {
      storeImage = "assets/ayame-logo-small.png";
    } else {
      storeImage = "assets/myjoy-logo-small.png";
    }
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {
        tabIndex = tabController.index;
      });
    });
    fetchData();
    super.initState();
  }

  fetchData() async {
    users = List<Map<String, dynamic>>.from((await getUsers())["users"]);
    branches =
        List<Map<String, dynamic>>.from((await getBranches())["branches"]);
    if (!mounted) return;
    setState(() {});
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
                child: PortalCard(portalName: "system management")),
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
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          controller: tabController,
                          indicatorColor: primaryColor,
                          indicatorWeight: 5,
                          labelColor: Colors.black,
                          labelStyle: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          tabs: const [
                            Tab(text: 'Branches'),
                            Tab(text: 'Users'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: tabController,
                            children: [
                              branches == null
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : branches!.isEmpty
                                      ? Center(
                                          child: Text(
                                            "No Branches yet.\nTap the + button to add a branch.",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14,
                                              color: grayText,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: branches!.length,
                                          itemBuilder: (context, index) {
                                            Map<String, dynamic> branch =
                                                branches![index];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                left: 10.0,
                                                right: 10,
                                                bottom: 10,
                                              ),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  Map<String, dynamic>
                                                      stateData = {
                                                    "branch_id": branch["id"],
                                                    "auth_token":
                                                        widget.stateData[
                                                            "auth_token"],
                                                    "branch_name":
                                                        branch["name"]
                                                  };
                                                  final res = await showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return EditBranchDialog(
                                                        stateData: stateData,
                                                      ); // Use the custom dialog widget
                                                    },
                                                  );
                                                  if (res != null &&
                                                      res == true) {
                                                    fetchData();
                                                  }
                                                },
                                                child: BranchCard(
                                                    branch: branch,
                                                    refreshCallback: fetchData),
                                              ),
                                            );
                                          }),
                              users == null
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : users!.isEmpty
                                      ? Center(
                                          child: Text(
                                            "No Users yet.\nTap the + button to add a user.",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14,
                                              color: grayText,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: users!.length,
                                          itemBuilder: (context, index) {
                                            Map<String, dynamic> user =
                                                users![index];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                left: 10.0,
                                                right: 10,
                                                bottom: 10,
                                              ),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  Map<String, dynamic>
                                                      stateData = user;
                                                  stateData["auth_token"] =
                                                      widget.stateData[
                                                          "auth_token"];
                                                  stateData["branches"] =
                                                      branches;
                                                  final res = await showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder:
                                                        (BuildContext context) {
                                                      return EditUserDialog(
                                                        stateData: stateData,
                                                      ); // Use the custom dialog widget
                                                    },
                                                  );
                                                  if (res != null &&
                                                      res == true) {
                                                    fetchData();
                                                  }
                                                },
                                                child: UserCard(
                                                    user: user,
                                                    refreshCallback: fetchData),
                                              ),
                                            );
                                          }),
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
          Positioned(
            bottom: 130,
            right: 55,
            child: GestureDetector(
              onTap: () async {
                final res = await showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    if (tabIndex == 0) {
                      final stateData = {
                        "auth_token": widget.stateData["auth_token"]
                      };
                      return AddBranchDialog(
                        stateData: stateData,
                      ); // Use the custom dialog widget
                    } else {
                      Map<String, dynamic> stateData = widget.stateData;
                      stateData["branches"] = branches;
                      return AddUserDialog(stateData: stateData);
                    }
                  },
                );
                if (res != null && res == true) {
                  setState(() {
                    branches = null;
                  });
                  fetchData();
                }
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  color: primaryColor,
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
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> getUsers() async {
    String url = '$baseURL/users';
    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;
    return responseData;
  }

  Future<Map<String, dynamic>> getBranches() async {
    String url = '$baseURL/branches';
    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;
    return responseData;
  }
}
