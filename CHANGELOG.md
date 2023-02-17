# Changelog

## 0.8.1
- Update deps
## 0.8.0
- __Breaking change__: ExInsights is no longer an application, you now need to start the Supervisor manually
- __Breaking change__: Configuring from `config.exs` was dropped in favor of passing arguments to the Supervisor. This change along with the one above should help making the library more flexible to configure
- _Possibly breaking change_: replaced Poison with Jason as the default json encoder
- cleaned up internals to make extending the library easier. Public interface has not changed.

## 0.7.0
- __Breaking change__: start time and dependency id parameters as part of request and track dependency payload (thanks @huderlem)

## 0.6.0
- __Breaking change__: custom tags as part of payload (thanks @huderlem)

## 0.5.2
- allow setting id explicitly on track_request

## 0.5.1
- fix dialyzer issue

## 0.5.0
- allow setting instrumentation key on a per request basis

## 0.4.1
- added measurements to request tracking (thanks @DevExpDev)

## 0.4.0
- added request tracking (thanks @lafka)
- formatted code files
- updated dependencies

## 0.3.1
- Minor changes in test suite
- Updated typespecs

## 0.3.0
- Added `track_exception`
- Added decorators for `track_event`, `track_exception`, and `track_dependency`
- Updated docs
- Cleaned up specs and added dialyzer

## 0.2.0
- Added `track_dependency` and `track_trace`
- Added `flush_interval_secs` config option
- Documentation changes

## 0.1.0
- Initial version
- Support for `track_event` and `track_metric`
