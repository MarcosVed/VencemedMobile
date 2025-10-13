// Adicione estes métodos no seu EstabelecimentoController.java

// Endpoint público para listar todos os estabelecimentos
@GetMapping("/listar")
public ResponseEntity<?> listarTodos() {
    List<Estabelecimento> estabelecimentos = estabelecimentoService.listarTodos();
    return ResponseEntity.ok(estabelecimentos);
}

// Endpoint para buscar por CEP
@GetMapping("/buscarPorCep/{cep}")
public ResponseEntity<?> buscarPorCep(@PathVariable String cep) {
    List<Estabelecimento> estabelecimentos = estabelecimentoService.buscarPorCep(cep);
    return ResponseEntity.ok(estabelecimentos);
}

// Adicione também este método no EstabelecimentoService.java
public List<Estabelecimento> buscarPorCep(String cep) {
    return estabelecimentoRepository.findByCep(cep);
}

// E no EstabelecimentoRepository.java (interface)
List<Estabelecimento> findByCep(String cep);