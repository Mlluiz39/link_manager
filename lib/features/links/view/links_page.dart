import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:convert';
import '../viewmodel/link_viewmodel.dart';
import '../model/link.dart';
import 'dart:math';

class LinksPage extends StatefulWidget {
  const LinksPage({Key? key}) : super(key: key);

  @override
  State<LinksPage> createState() => _LinksPageState();
}

class _LinksPageState extends State<LinksPage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _landingController;
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _landingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _landingController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LinkViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gerenciador de Links',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
        elevation: 2,
        actions: [
          if (_selectedIndex == 1) ...[
            IconButton(
              icon: const Icon(Icons.backup),
              tooltip: 'Backup',
              onPressed: () => _backupLinks(context, viewModel.links),
            ),
            IconButton(
              icon: const Icon(Icons.restore),
              tooltip: 'Restaurar',
              onPressed: () => _restoreLinks(context, viewModel),
            ),
          ],
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _selectedIndex == 0
            ? FadeTransition(
                opacity: _landingController,
                child: _buildLanding(context),
              )
            : FadeTransition(
                opacity: _listController..forward(),
                child: _buildLinksList(context, viewModel),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 1) {
              _listController.reset();
              _listController.forward();
            }
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.link), label: 'Links'),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => _showAddLinkDialog(context, viewModel),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
              backgroundColor: Colors.purple,
            )
          : null,
    );
  }

  Widget _buildLanding(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSlide(
              offset: const Offset(0, -0.3),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Icon(Icons.link, size: 100, color: Colors.purple),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedSlide(
              offset: const Offset(0, 0.3),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              child: const Text(
                'Todos os seus links em um só lugar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedOpacity(
              opacity: 1,
              duration: const Duration(milliseconds: 900),
              child: const Text(
                'Gerencie e compartilhe seus links de todas as redes sociais de forma simples e elegante',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black54, height: 1.4),
              ),
            ),
            const SizedBox(height: 52),
            AnimatedSlide(
              offset: const Offset(0, 0.2),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialIcon(Icons.facebook, Colors.purple[800]),
                  const SizedBox(width: 18),
                  _socialIcon(Icons.ondemand_video, Colors.purple), // YouTube
                  const SizedBox(width: 18),
                  _socialIcon(Icons.music_note, Colors.purpleAccent), // TikTok
                  const SizedBox(width: 18),
                  _socialIcon(
                    Icons.alternate_email,
                    Colors.deepPurple,
                  ), // Twitter
                  const SizedBox(width: 18),
                  _socialIcon(Icons.camera_alt, Colors.purple), // Instagram
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _socialIcon(IconData icon, Color? color) {
    return CircleAvatar(
      // ignore: deprecated_member_use
      backgroundColor: color?.withOpacity(0.15),
      radius: 28,
      child: Icon(icon, color: color, size: 32),
    );
  }

  Widget _buildLinksList(BuildContext context, LinkViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: viewModel.links.isEmpty
          ? Center(
              child: Text(
                'Nenhum link cadastrado.\nToque em + para adicionar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 18),
              ),
            )
          : ListView.separated(
              itemCount: viewModel.links.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final link = viewModel.links[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: _getColorForType(link.type),
                      child: Icon(
                        _getIconForType(link.type),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      link.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      link.url,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.blueGrey,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => viewModel.removeLink(link.id),
                      tooltip: 'Remover',
                    ),
                    onTap: () => _showOptionsDialog(context, viewModel, link),
                  ),
                );
              },
            ),
    );
  }

  void _showAddLinkDialog(
    BuildContext context,
    LinkViewModel viewModel, {
    Link? linkToEdit,
  }) {
    final titleController = TextEditingController(
      text: linkToEdit?.title ?? '',
    );
    final urlController = TextEditingController(text: linkToEdit?.url ?? '');
    String type = linkToEdit?.type ?? 'Instagram';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            linkToEdit == null ? 'Adicionar Link' : 'Editar Link',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Instagram',
                    child: Text('Instagram'),
                  ),
                  DropdownMenuItem(value: 'YouTube', child: Text('YouTube')),
                  DropdownMenuItem(value: 'Facebook', child: Text('Facebook')),
                  DropdownMenuItem(value: 'TikTok', child: Text('TikTok')),
                  DropdownMenuItem(value: 'Outro', child: Text('Outro')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    type = value;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    urlController.text.isNotEmpty) {
                  if (linkToEdit == null) {
                    final newLink = Link(
                      id: Random().nextInt(100000).toString(),
                      title: titleController.text,
                      url: urlController.text,
                      type: type,
                    );
                    viewModel.addLink(newLink);
                  } else {
                    final updatedLink = linkToEdit.copyWith(
                      title: titleController.text,
                      url: urlController.text,
                      type: type,
                    );
                    viewModel.updateLink(updatedLink);
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text(linkToEdit == null ? 'Adicionar' : 'Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showOptionsDialog(
    BuildContext context,
    LinkViewModel viewModel,
    Link link,
  ) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Opções'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              _showOpenDialog(context, link.url);
            },
            child: const ListTile(
              leading: Icon(Icons.open_in_new),
              title: Text('Abrir link'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: link.url));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link copiado para a área de transferência!'),
                ),
              );
            },
            child: const ListTile(
              leading: Icon(Icons.copy),
              title: Text('Copiar link'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              _showAddLinkDialog(context, viewModel, linkToEdit: link);
            },
            child: const ListTile(
              leading: Icon(Icons.edit),
              title: Text('Editar link'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(),
            child: const ListTile(
              leading: Icon(Icons.close),
              title: Text('Cancelar'),
            ),
          ),
        ],
      ),
    );
  }

  void _showOpenDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abrir Link'),
        content: const Text('Deseja abrir este link no app nativo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Não foi possível abrir o link.'),
                  ),
                );
              }
            },
            child: const Text('Abrir'),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Instagram':
        return Icons.camera_alt;
      case 'YouTube':
        return Icons.ondemand_video;
      case 'Facebook':
        return Icons.facebook;
      default:
        return Icons.link;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'Instagram':
        return Colors.purple;
      case 'YouTube':
        return Colors.purple;
      case 'Facebook':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _backupLinks(BuildContext context, List<Link> links) async {
    try {
      final jsonLinks = jsonEncode(links.map((e) => e.toMap()).toList());
      String? outputPath;
      if (Platform.isAndroid ||
          Platform.isWindows ||
          Platform.isLinux ||
          Platform.isMacOS) {
        String? selectedPath = await FilePicker.platform.getDirectoryPath();
        if (selectedPath == null) return; // usuário cancelou
        outputPath = '$selectedPath/links_backup.json';
      } else {
        final directory = await getApplicationDocumentsDirectory();
        outputPath = '${directory.path}/links_backup.json';
      }
      final file = File(outputPath);
      await file.writeAsString(jsonLinks);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup salvo em: ${file.path}'),
          action: SnackBarAction(
            label: 'Compartilhar',
            onPressed: () => Share.shareXFiles([
              XFile(file.path),
            ], text: 'Meus links salvos!'),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao salvar backup.')));
    }
  }

  Future<void> _restoreLinks(
    BuildContext context,
    LinkViewModel viewModel,
  ) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        final links = jsonList.map((e) => Link.fromMap(e)).toList();
        for (var link in links) {
          viewModel.addLink(link);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Links restaurados com sucesso!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao restaurar backup.')),
      );
    }
  }
}
