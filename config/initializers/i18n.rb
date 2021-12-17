# frozen_string_literal: true

I18n.config.interpolation_patterns << /\{([\w|]+)\}/ # also match patterns like {key} without leading % before {
