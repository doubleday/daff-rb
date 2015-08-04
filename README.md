daff: data diff
===============

This is a ruby build (version 1.2.8 at the time of writing) of the daff library form https://github.com/paulfitz/daff.

This includes a small patch in daff.rb

    +20 return old_get.bind(self).(x) if x.is_a?(Range)

which allows using daff in a rake run.
