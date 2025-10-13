// Adicione este método no seu UsuarioController.java

@PutMapping("/atualizar/{id}")
public ResponseEntity<Usuario> atualizarUsuario(@PathVariable long id, @RequestBody Usuario usuarioAtualizado) {
    Usuario usuario = usuarioService.atualizarUsuario(id, usuarioAtualizado);
    if (usuario != null) {
        return ResponseEntity.ok(usuario);
    } else {
        throw new ResourceNotFoundException("Usuário não encontrado!");
    }
}

// E adicione este método no seu UsuarioService.java

@Transactional
public Usuario atualizarUsuario(long id, Usuario dadosAtualizados) {
    Optional<Usuario> _usuario = usuarioRepository.findById(id);
    if (_usuario.isPresent()) {
        Usuario usuario = _usuario.get();
        
        // Atualizar apenas os campos permitidos (não senha nem email)
        if (dadosAtualizados.getNome() != null) {
            usuario.setNome(dadosAtualizados.getNome());
        }
        
        return usuarioRepository.save(usuario);
    }
    return null;
}