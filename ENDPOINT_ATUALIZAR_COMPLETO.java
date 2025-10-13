// Adicione este método no seu UsuarioController.java

@PutMapping("/atualizar/{id}")
public ResponseEntity<Usuario> atualizarUsuario(@PathVariable long id, @RequestBody Map<String, Object> dadosAtualizados) {
    Usuario usuario = usuarioService.atualizarUsuario(id, dadosAtualizados);
    if (usuario != null) {
        return ResponseEntity.ok(usuario);
    } else {
        throw new ResourceNotFoundException("Usuário não encontrado!");
    }
}

// E atualize este método no seu UsuarioService.java

@Transactional
public Usuario atualizarUsuario(long id, Map<String, Object> dadosAtualizados) {
    Optional<Usuario> _usuario = usuarioRepository.findById(id);
    if (_usuario.isPresent()) {
        Usuario usuario = _usuario.get();
        
        // Atualizar apenas os campos permitidos
        if (dadosAtualizados.containsKey("nome")) {
            usuario.setNome((String) dadosAtualizados.get("nome"));
        }
        
        return usuarioRepository.save(usuario);
    }
    return null;
}