# Change log

## master

- [PR#76](https://github.com/DmitryTsepelev/rubocop-graphql/pull/76) [FieldMethod, FieldHashKey] Don't raise offense when method/hash key name conflicts with keyword ([@roger-kang-mo][])
- 
## 0.13.0 (2022-02-11)

- [PR#75](https://github.com/DmitryTsepelev/rubocop-graphql/pull/75) Update Ordered Arguments Auto Correction to Respect Blocks ([@roger-kang-mo][])
- [PR#72](https://github.com/DmitryTsepelev/rubocop-graphql/pull/72) `UnusedArgument` Do not look for resolve method in nested classes ([@nvasilevski][])

## 0.12.3 (2022-01-08)

- [PR#70](https://github.com/DmitryTsepelev/rubocop-graphql/pull/70) Remove unused NodeUniqueness#nested_class? method ([@nvasilevski][])
- [PR#71](https://github.com/DmitryTsepelev/rubocop-graphql/pull/71) `UnusedArgument`: Ignore arguments defined in a nested class ([@nvasilevski][])

## 0.12.2 (2022-01-07)

- [PR#69](https://github.com/DmitryTsepelev/rubocop-graphql/pull/69) Scope definitions per full namespace ([@nvasilevski][])
- [PR#68](https://github.com/DmitryTsepelev/rubocop-graphql/pull/68) Extract argument/field uniqueness common methods ([@nvasilevski][])
- [PR#67](https://github.com/DmitryTsepelev/rubocop-graphql/pull/67) Respect :as keyword even without :loads  ([@nvasilevski][])

## 0.12.1 (2022-01-05 🎄)

- [PR#66](https://github.com/DmitryTsepelev/rubocop-graphql/pull/66) `UnusedArgument` Consider optional kwarg argument as declared ([@nvasilevski][])
- [PR#65](https://github.com/DmitryTsepelev/rubocop-graphql/pull/65) Fix GraphQL/UnusedArgument cop to respect loads and as keyword ([@aishek][])

## 0.12.0 (2021-12-30 🎄)

- [PR#61](https://github.com/DmitryTsepelev/rubocop-graphql/pull/61) Implement UnusedArgument cop ([@aishek][])
- [PR#60](https://github.com/DmitryTsepelev/rubocop-graphql/pull/60) `ArgumentUniqueness` Scope argument definitions per class name ([@nvasilevski][])

## 0.11.3 (2021-12-22)

- [PR#57](https://github.com/DmitryTsepelev/rubocop-graphql/pull/57) [FieldUniqueness] Do not consider nested class fields as violations ([@nvasilevski][])

## 0.11.2 (2021-12-03)

- [PR#55](https://github.com/DmitryTsepelev/rubocop-graphql/pull/55) Exclude spec directories for all cops ([@DmitryTsepelev][])

## 0.11.1 (2021-12-01)

- [PR#52](https://github.com/DmitryTsepelev/rubocop-graphql/pull/52) Allow object description to be a constant ([@nevesenin][])

## 0.11.0 (2021-11-25)

- [PR#50](https://github.com/DmitryTsepelev/rubocop-graphql/pull/50) Implement `GraphQL/FieldUniqueness` and `GraphQL/ArgumentUniqueness` cops ([@justisb][])

## 0.10.3 (2021-11-09)

- Add `GraphQL/OrderedFields` and `GraphQL/OrderedArguments` to `default.yml` ([@DmitryTsepelev][])

## 0.10.2 (2021-08-30)

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
[@justisb]: https://github.com/justisb
[@nevesenin]: https://github.com/nevesenin
[@nvasilevski]: https://github.com/nvasilevski
[@aishek]: https://github.com/aishek
[@roger-kang-mo]: https://github.com/roger-kang-mo
[@alex4787]: https://github.com/alex4787
