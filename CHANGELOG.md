# Change log

## master

- [PR#45](https://github.com/DmitryTsepelev/rubocop-graphql/pull/45) Fix false-positive in FieldDescription when field has block with begin node ([@DmitryTsepelev][])

## 0.10.1 (2021-08-19)

- [PR#44](https://github.com/DmitryTsepelev/rubocop-graphql/pull/44)  FieldHashKey only matches symbol or string keys ([@aaronfrary][])

## 0.10.0 (2021-07-23)

- [PR#40](https://github.com/DmitryTsepelev/rubocop-graphql/pull/40) Autocorrect field names ([@drapergeek][])

## 0.9.0 (2021-05-18)

- [PR#39](https://github.com/DmitryTsepelev/rubocop-graphql/pull/39) Implement Rubocop for detecting legacy DSL types ([@danielvdao][])
- [PR#37](https://github.com/DmitryTsepelev/rubocop-graphql/pull/37) Use new Base for cops ([@DmitryTsepelev][])

## 0.8.2 (2021-04-23)

- [PR#36](https://github.com/DmitryTsepelev/rubocop-graphql/pull/36) Remove hacks around base class, use built-in Include to filter files ([@DmitryTsepelev][])

## 0.8.1 (2021-04-09)

- [PR#35](https://github.com/DmitryTsepelev/rubocop-graphql/pull/35) Improve multiline description detection ([@bessey][])

## 0.8.0 (2021-04-08)

- [PR#32](https://github.com/DmitryTsepelev/rubocop-graphql/pull/32) ExtractInputType: show all excess args in offense ([@bessey][])

## 0.7.0 (2021-03-17)

- [PR#34](https://github.com/DmitryTsepelev/rubocop-graphql/pull/34) Add OrderedArguments cop ([@kiskoza][])
- [PR#33](https://github.com/DmitryTsepelev/rubocop-graphql/pull/33) Add autocorrect for OrderedFields cop ([@kiskoza][])

## 0.6.2 (2021-03-03)

- [PR#31](https://github.com/DmitryTsepelev/rubocop-graphql/pull/31) ObjectDescription cop handles multiline descriptions ([@DmitryTsepelev][])

## 0.6.1 (2020-10-31 🎃)

- [PR#27](https://github.com/DmitryTsepelev/rubocop-graphql/pull/27) Relax rubocop version ([@DmitryTsepelev][])

## 0.6.0 (2020-10-22)

- [PR#26](https://github.com/DmitryTsepelev/rubocop-graphql/pull/26) Support rubocop 1.0 ([@DmitryTsepelev][])

## 0.5.0 (2020-10-02)

- [PR#25](https://github.com/DmitryTsepelev/rubocop-graphql/pull/25) Add OrderedFields cop ([@kiskoza][])

## 0.4.1 (2020-08-17)

- [PR#24](https://github.com/DmitryTsepelev/rubocop-graphql/pull/24) Support rubocop 0.89, remove standard ([@DmitryTsepelev][])

## 0.4.0 (2020-07-30)

- [PR#22](https://github.com/DmitryTsepelev/rubocop-graphql/pull/22) Add FieldHashKey cop with autocorrect ([@adelnabiullin][])

## 0.3.1 (2020-07-26)

- [PR#21](https://github.com/DmitryTsepelev/rubocop-graphql/pull/21) Support type classes nested in modules ([@swalkinshaw][])

## 0.3.0 (2020-07-21)

- [PR#20](https://github.com/DmitryTsepelev/rubocop-graphql/pull/20) Fix NodePattern for fields without a name ([@swalkinshaw][])
- [PR#19](https://github.com/DmitryTsepelev/rubocop-graphql/pull/19) Gracefully handle fields/arguments without kwargs ([@swalkinshaw][])
- [PR#15](https://github.com/DmitryTsepelev/rubocop-graphql/pull/15) Fix example for GraphQL/ArgumentDescription ([@kiskoza][])
- [PR#14](https://github.com/DmitryTsepelev/rubocop-graphql/pull/14) Implement ObjectDescription cop ([@yaorlov][])

## 0.2.0 (2020-07-02)

- [PR#13](https://github.com/DmitryTsepelev/rubocop-graphql/pull/13) Implement field name and argument name cops ([@DmitryTsepelev][])
- [PR#12](https://github.com/DmitryTsepelev/rubocop-graphql/pull/12) Implement extract input type cop ([@DmitryTsepelev][])
- [PR#11](https://github.com/DmitryTsepelev/rubocop-graphql/pull/11) Implement argument description cop, tweak field description cop  ([@DmitryTsepelev][])
- [PR#10](https://github.com/DmitryTsepelev/rubocop-graphql/pull/10) Add autocorrect to FieldMethod and FieldDefinitions cops ([@DmitryTsepelev][])
- [PR#7](https://github.com/DmitryTsepelev/rubocop-graphql/pull/7) Implement ExtractType cop ([@0legovich][])

## 0.1.3 (2020-06-01 ☀️)

- [PR#6](https://github.com/DmitryTsepelev/rubocop-graphql/pull/6) Implement FieldMethod cop ([@DmitryTsepelev][])

## 0.1.2 (2020-05-25)

- Support fields with block in FieldDefinitions cop ([@DmitryTsepelev][])

## 0.1.1 (2020-05-25)

- Implement 'Patterns' support for config ([@DmitryTsepelev][])

## 0.1.0 (2020-05-21)

- Initial version ([@DmitryTsepelev][])

[@DmitryTsepelev]: https://github.com/DmitryTsepelev
[@0legovich]: https://github.com/0legovich
[@kiskoza]: https://github.com/kiskoza
[@yaorlov]: https://github.com/yaorlov
[@swalkinshaw]: https://github.com/swalkinshaw
[@adelnabiullin]: https://github.com/adelnabiullin
[@bessey]: https://github.com/bessey
[@danielvdao]: https://github.com/danielvdao
[@drapergeek]: https://github.com/drapergeek
[@aaronfrary]: https://github.com/aaronfrary
