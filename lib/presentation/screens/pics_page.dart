import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pics/bloc/auth_bloc.dart';
import 'package:pics/bloc/pics_bloc.dart';
import 'package:pics/presentation/widgets/loading_indicator_widget.dart';

class PicsPage extends StatefulWidget {
  PicsPage({Key? key}) : super(key: key);

  @override
  _PicsPageState createState() => _PicsPageState();
}

class _PicsPageState extends State<PicsPage> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> handleUploadSource(ImageSource source) async {
    final file = await ImagePicker().pickImage(source: source);
    BlocProvider.of<PicsBloc>(context).add(LoadPic(file: file));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PicsBloc, PicsState>(
        listener: (context, state) {
          if (state is PicsLoadFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.error),
                ),
              );
          }
        },
        buildWhen: (previous, current) => current is! PicsLoadFailure,
        builder: (context, state) {
          if (state is PicsLoadInProgress)
            return Scaffold(body: LoadingIndicatorWidget());
          else if (state is PicsLoadSuccess) {
            return Scaffold(
                drawer: Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      DrawerHeader(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                          ),
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              if (state is Authenticated) {
                                return Text("Phone: ${state.getUser().phoneNumber}",
                                    style: Theme.of(context).textTheme.subtitle1);
                              } else {
                                return SizedBox();
                              }
                            },
                          )),
                      ListTile(
                        title: const Text('Logout'),
                        onTap: () {
                          BlocProvider.of<AuthBloc>(context).add(LoggedOut());
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: Icon(Icons.camera_alt),
                                title: Text('Camera'),
                                onTap: () {
                                  Navigator.pop(context);
                                  handleUploadSource(ImageSource.camera);
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.photo),
                                title: Text('Gallery'),
                                onTap: () {
                                  Navigator.pop(context);
                                  handleUploadSource(ImageSource.gallery);
                                },
                              ),
                            ],
                          );
                        });
                  },
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.add),
                ),
                appBar: AppBar(
                  title: Text('My pics'),
                  centerTitle: true,
                ),
                body: (state.pics.isEmpty)
                    ? Padding(padding: EdgeInsets.all(20), child: Text("There are no images. Click + to add"))
                    : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 15.0,
                        crossAxisSpacing: 15.0,
                        childAspectRatio: 0.8),
                    primary: false,
                    shrinkWrap: true,
                    controller: _controller,
                    itemCount: state.pics.length,
                    itemBuilder: (context, index) {
                      var pic = state.pics[index];
                      return Dismissible(
                          key: UniqueKey(),
                          confirmDismiss: (DismissDirection direction) async {
                            return await showDialog(
                                context: context,
                                builder: (BuildContext ctx) {
                                  return AlertDialog(
                                    title: Text('Please Confirm'),
                                    content: Text('Are you sure to remove the pic?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: Text('Yes')),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: Text('No'))
                                    ],
                                  );
                                });
                          },
                          onDismissed: (direction) {
                            BlocProvider.of<PicsBloc>(context).add(RemovePic(pic: pic));
                          },
                          child: Container(
                              child: pic.url == ""
                                  ? LoadingIndicatorWidget()
                                  : CachedNetworkImage(
                                imageUrl: pic.url,
                                placeholder: (context, url) => LoadingIndicatorWidget(),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).dividerColor,
                              )));
                    }));
          } else {
            return Scaffold(body: LoadingIndicatorWidget());
          }
        });
  }
}
