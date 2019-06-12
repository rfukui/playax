# Teste Locaweb v.0.0.3

**Este é um teste escrito como parte do processo de seleção da Playax**
**Totalmente escrito em ruby + Framework RAILS e RSPEC**

## Requerimentos de instalação e execução do programa:
O programa roda em um container tipo Docker, com Dockerfile já pronto
```
$ docker build -t app .
$ docker run -it --rm -v "$PWD":/usr/src/app -w /usr/src/app ruby:2.6.3 bash
```

## Executando testes:
O build já executa os testes no momento da criação da imagem Docker
