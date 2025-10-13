// Adicione este método no seu EstabelecimentoController.java

@GetMapping("/publico")
public ResponseEntity<?> listarPublico() {
    List<Estabelecimento> estabelecimentos = estabelecimentoService.listarTodos();
    return ResponseEntity.ok(estabelecimentos);
}

// Ou se preferir, modifique o método existente para não precisar de autenticação:

@GetMapping("/listar")
public ResponseEntity<?> listarTodos() {
    List<Estabelecimento> estabelecimentos = estabelecimentoService.listarTodos();
    return ResponseEntity.ok(estabelecimentos);
}