import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageUtils {
  /// Converte uma string base64 para Uint8List
  static Uint8List? base64ToBytes(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return null;
    }
    
    try {
      // Remove prefixos como "data:image/jpeg;base64," se existirem
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }
      
      return base64Decode(cleanBase64);
    } catch (e) {
      print('Erro ao converter base64 para bytes: $e');
      return null;
    }
  }

  /// Cria um widget Image a partir de bytes
  static Widget buildImageFromBytes(
    Uint8List? imageBytes, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (imageBytes == null) {
      return errorWidget ?? _defaultErrorWidget(width, height);
    }

    return Image.memory(
      imageBytes,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _defaultErrorWidget(width, height);
      },
    );
  }

  /// Widget padrão para quando não há imagem
  static Widget _defaultErrorWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(
        Icons.store,
        size: height != null ? height * 0.3 : 50,
        color: Colors.grey[600],
      ),
    );
  }

  /// Converte base64 diretamente para widget Image
  static Widget buildImageFromBase64(
    String? base64String, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    final bytes = base64ToBytes(base64String);
    return buildImageFromBytes(
      bytes,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}