# Change log

## master

- [PR#124](https://github.com/DmitryTsepelev/rubocop-graphql/pull/124) UnnecessaryFieldAlias checks for method, hash_key and resolver_method ([@DmitryTsepelev][])

## 1.0.1 (2023-03-13)

- [PR#120](https://github.com/DmitryTsepelev/rubocop-graphql/pull/120) FieldDefinitions handles method calls between fields inside nested modules ([@DmitryTsepelev][])
- [PR#121](https://github.com/DmitryTsepelev/rubocop-graphql/pull/121) NotAuthorizedNodeType supports authorized? inside class block ([@DmitryTsepelev][])

## 1.0.0 (2023-02-26) 🚀

- [PR#111](https://github.com/DmitryTsepelev/rubocop-graphql/pull/111) Fix GraphQL/OrderedFields to handle blocks properly ([@danielvdao][])
- [PR#115](https://github.com/DmitryTsepelev/rubocop-graphql/pull/115) Add NotAuthorizedNodeType cop ([@DmitryTsepelev][])
- [PR#114](https://github.com/DmitryTsepelev/rubocop-graphql/pull/114) Add MaxDepthSchema and MaxComplextySchema cops ([@DmitryTsepelev][])
- [PR#113](https://github.com/DmitryTsepelev/rubocop-graphql/pull/113) Add GraphqlName cop ([@DmitryTsepelev][])
- [PR#112](https://github.com/DmitryTsepelev/rubocop-graphql/pull/112) Make FieldDefinitions work with modules ([@DmitryTsepelev][])

## 0.19.0 (2023-01-15)

- [PR#107](https://github.com/DmitryTsepelev/rubocop-graphql/pull/107) Make ExtractInputType check nested folders ([@arenclissold][])
- [PR#109](https://github.com/DmitryTsepelev/rubocop-graphql/pull/109) [OrderedFields] [OrderedArguments] Handle heredocs when auto-correcting ([@Darhazer][])

## 0.18.0 (2022-10-30)

- [PR#102](https://github.com/DmitryTsepelev/rubocop-graphql/pull/102) Add UnnecessaryFieldCamelize ([@danielvdao][])
- [PR#103](https://github.com/DmitryTsepelev/rubocop-graphql/pull/103) Add UnnecessaryArgumentCamelize ([@danielvdao][])

## 0.17.0 (2022-10-27)

- [PR#100](https://github.com/DmitryTsepelev/rubocop-graphql/pull/100) Add UnnecessaryFieldAlias rule ([@danielvdao][])
- [PR#99](https://github.com/DmitryTsepelev/rubocop-graphql/pull/99) ExtractInputType: include only mutations ([@DmitryTsepelev][])
- [PR#98](https://github.com/DmitryTsepelev/rubocop-graphql/pull/98) ObjectDescription: exclude QueryContext ([@DmitryTsepelev][])

## 0.16.0 (2022-10-24)

- [PR#97](https://github.com/DmitryTsepelev/rubocop-graphql/pull/97) Check #authorized? for unused arguments ([@palkan][])

## 0.15.1 (2022-10-11)

- [PR#96](https://github.com/DmitryTsepelev/rubocop-graphql/pull/96) Allow method calls without explicit receiver in object descriptions ([@imustafin][])

## 0.15.0 (2022-09-28)

- [PR#94](https://github.com/DmitryTsepelev/rubocop-graphql/pull/94) Add cop for multiple field definitions, update field definitions cop to handle multiple definitions ([@ydah][])

## 0.14.6 (2022-08-31 🍂)

- [PR#93](https://github.com/DmitryTsepelev/rubocop-graphql/pull/93) Enable InternalAffairs cop ([@ydah][])
- [PR#91](https://github.com/DmitryTsepelev/rubocop-graphql/pull/91) Fix GraphQL/FieldHashKey keyword detection when string key is used ([@r7kamura][])

## 0.14.5 (2022-07-02)

- [PR#89](https://github.com/DmitryTsepelev/rubocop-graphql/pull/89) [ExtractType]: add has prefix to default values for config ([@MH4GF][])

## 0.14.4 (2022-06-24)

- [PR#86](https://github.com/DmitryTsepelev/rubocop-graphql/pull/86) [OrderedFields] [OrderedArguments]: Improve auto-correction with multiple offenses ([@Darhazer][])
- [PR#85](https://github.com/DmitryTsepelev/rubocop-graphql/pull/85) [UnusedArgument]: Fix false positive when fields use arguments ([@Darhazer][])

## 0.14.3 (2022-05-16)

- [PR#82](https://github.com/DmitryTsepelev/rubocop-graphql/pull/82) [ArgumentUniqueness]: properly handle ivars in the field name ([@DmitryTsepelev][])

## 0.14.2 (2022-03-27)

- [PR#79](https://github.com/DmitryTsepelev/rubocop-graphql/pull/79) [UnusedArgument] Ignore forward arguments ([@nipe0324][])

## 0.14.1 (2022-03-25)

- [PR#78](https://github.com/DmitryTsepelev/rubocop-graphql/pull/78) [FieldDescription, ArgumentDescription] Support descriptions in blocks with an argument ([@alex4787][])

## 0.14.0 (2022-03-23)

- [PR#77](https://github.com/DmitryTsepelev/rubocop-graphql/pull/77) [FieldDefinitions] [FieldDefinitions] Support heredoc descriptionss ([@alex4787][])
- [PR#77](https://github.com/DmitryTsepelev/rubocop-graphql/pull/77) [FieldDefinitions] Add support for fields sharing resolvers ([@alex4787][])
- [PR#77](https://github.com/DmitryTsepelev/rubocop-graphql/pull/77) [FieldDefinitions] Add Sorbet support ([@alex4787][])
- [PR#76](https://github.com/DmitryTsepelev/rubocop-graphql/pull/76) [FieldMethod, FieldHashKey] Don't raise offense when method/hash key name conflicts with keyword ([@alex4787][])

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
[@nipe0324]: https://github.com/nipe0324
[@Darhazer]: https://github.com/Darhazer
[@MH4GF]: https://github.com/MH4GF
[@r7kamura]: https://github.com/r7kamura
[@ydah]: https://github.com/ydah
[@toneymathews]: https://github.com/toneymathews
[@imustafin]: https://github.com/imustafin
[@palkan]: https://github.com/palkan
[@arenclissold]: https://github.com/arenclissold
