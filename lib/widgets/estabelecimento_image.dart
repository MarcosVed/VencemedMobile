import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../services/estabelecimento_service.dart';

class EstabelecimentoImage extends StatefulWidget {
  final int estabelecimentoId;
  final double? width;
  final double? height;
  final BoxFit fit;

  const EstabelecimentoImage({
    super.key,
    required this.estabelecimentoId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<EstabelecimentoImage> createState() => _EstabelecimentoImageState();
}

class _EstabelecimentoImageState extends State<EstabelecimentoImage> {
  Uint8List? _imageBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final imageBytes = await EstabelecimentoService.buscarImagemEstabelecimento(widget.estabelecimentoId);
    if (mounted) {
      setState(() {
        _imageBytes = imageBytes;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[300],
      child: Icon(
        Icons.store,
        size: widget.height != null ? widget.height! * 0.5 : 50,
        color: Colors.grey[600],
      ),
    );
  }
}