import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_pdf/src/common/widgets/appbar_widget.dart';
import 'package:task_pdf/src/home/bloc/home_bloc.dart';

class HomePageTablet extends StatelessWidget {
  const HomePageTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomePageBloc, HomePageState>(
      listenWhen: (previous, current) =>
          previous.downloadStatus != current.downloadStatus ||
          previous.message != current.message,
      listener: (context, state) {
        if (state.downloadStatus == DownloadStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Download completed successfully"),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.downloadStatus == DownloadStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Download failed: ${state.message}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<HomePageBloc, HomePageState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBarWidger(title: 'File Upload Dashboard'),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Upload your files",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: state.isUploading
                              ? null
                              : () {
                                  context.read<HomePageBloc>().add(
                                    const UploadFileRequested(),
                                  );
                                },
                          icon: state.isUploading
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.upload_file),
                          label: Text(
                            state.isUploading ? "Uploading..." : "Choose File",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    "Uploaded Files",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: state.files.isNotEmpty
                        ? ListView.separated(
                            itemCount: state.files.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) {
                              final file = state.files[index];
                              final name = file['name'] as String;
                              final url = file['url'] as String;
                              final isImage =
                                  name.endsWith(".jpg") ||
                                  name.endsWith(".jpeg") ||
                                  name.endsWith(".png");

                              return ListTile(
                                leading: const Icon(
                                  Icons.insert_drive_file,
                                  color: Colors.indigo,
                                ),
                                title: Text(name),
                                subtitle: Text(
                                  "Uploaded: ${file['uploadedAt']}",
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isImage)
                                      IconButton(
                                        icon: const Icon(Icons.remove_red_eye),
                                        tooltip: "Preview",
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: Text(name),
                                              content: Image.network(
                                                url,
                                                width: 300,
                                                height: 300,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.download),
                                      tooltip: "Download",
                                      onPressed: () {
                                        context.read<HomePageBloc>().add(
                                          DownloadFileRequested(
                                            fileName: name,
                                            downloadUrl: url,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : const Center(child: Text("No files uploaded yet.")),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
