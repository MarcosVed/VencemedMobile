# Instruções para Implementação do Mapa Interativo

## Dependências Adicionadas

As seguintes dependências foram adicionadas ao `pubspec.yaml`:

```yaml
flutter_map: ^7.0.2      # Para mapas interativos com Leaflet
latlong2: ^0.9.1         # Para coordenadas geográficas
http: ^1.2.2             # Para requisições HTTP (busca de CEP)
geolocator: ^13.0.1      # Para localização do usuário
```

## Instalação das Dependências

Execute o comando no terminal dentro da pasta do projeto:

```bash
flutter pub get
```

## Funcionalidades Implementadas

### 1. Mapa Interativo
- Mapa usando Leaflet (OpenStreetMap)
- Marcadores para estabelecimentos e localização atual
- Zoom e navegação interativa

### 2. Busca por CEP
- Campo de entrada para CEP (8 dígitos)
- Integração com API ViaCEP
- Atualização automática do mapa e lista

### 3. Lista Ordenada por Distância
- Estabelecimentos ordenados por proximidade
- Exibição da distância em km
- Informações completas de cada estabelecimento

### 4. Interação
- Clique nos marcadores do mapa para selecionar
- Lista sincronizada com o mapa
- Navegação para detalhes do estabelecimento

## Arquivos Modificados/Criados

1. **pubspec.yaml** - Dependências adicionadas
2. **lib/models/estabelecimento.dart** - Adicionadas coordenadas (latitude/longitude)
3. **lib/services/cep_service.dart** - Novo serviço para busca de CEP e cálculo de distâncias
4. **lib/selecao_estabelecimento_screen.dart** - Tela completamente reformulada com mapa
5. **android/app/src/main/AndroidManifest.xml** - Permissões de internet e localização

## Como Usar

1. Abra a tela de seleção de estabelecimento
2. Digite um CEP válido no campo de busca
3. Clique no botão de pesquisa
4. O mapa será atualizado mostrando sua localização e as farmácias próximas
5. A lista abaixo será ordenada por distância
6. Clique em qualquer marcador no mapa ou item da lista para selecionar

## Observações Técnicas

- As coordenadas dos estabelecimentos são simuladas para demonstração
- Em produção, você deve usar um serviço de geocoding real
- O serviço de CEP usa a API gratuita ViaCEP
- O cálculo de distância usa a fórmula de Haversine

## Próximos Passos (Opcional)

1. Integrar com serviço de geocoding real (Google Maps API, etc.)
2. Adicionar localização GPS do usuário
3. Implementar filtros por tipo de estabelecimento
4. Adicionar rotas no mapa
5. Cache de dados para melhor performance