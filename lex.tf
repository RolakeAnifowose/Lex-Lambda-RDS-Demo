resource "aws_lexv2models_bot" "AppointmentBot" {
  name                        = "AppointmentBot"
  role_arn                    = aws_iam_role.lexv2-role.arn
  type                        = "Bot"
  idle_session_ttl_in_seconds = 60

  description = "Bot to book appointments for pet grooming"

  data_privacy {
    child_directed = false
  }
}

resource "aws_lexv2models_bot_locale" "locale" {
  bot_id                           = aws_lexv2models_bot.AppointmentBot.id
  locale_id                        = "en_US"
  n_lu_intent_confidence_threshold = 0.7
  bot_version                      = "DRAFT"

#   voice_settings {
#     voice_id = "Danielle"
#     engine   = "standard"
#   }
}

resource "aws_lexv2models_bot_version" "bot-version" {
  bot_id = aws_lexv2models_bot.AppointmentBot.id
  locale_specification = {
    (aws_lexv2models_bot_locale.locale.locale_id) = {
      source_bot_version = "DRAFT"
    }
  }
}

resource "aws_lexv2models_intent" "Book" {
  name        = "Book"
  bot_id      = aws_lexv2models_bot.AppointmentBot.id
  locale_id   = aws_lexv2models_bot_locale.locale.locale_id
  bot_version = "DRAFT"

  fulfillment_code_hook {
    enabled = true
  }

  dialog_code_hook {
    enabled = true
  }

  sample_utterance {
    utterance = "Book an appointment"
  }

  sample_utterance {
    utterance = "I want to make a animal grooming reservation"
  }

  sample_utterance {
    utterance = "Book an appointment in the animal grooming salon"
  }

  sample_utterance {
    utterance = "I want to make an appointment for {AnimalName}"
  }

  sample_utterance {
    utterance = "Schedule a grooming session for my pet"
  }

  sample_utterance {
    utterance = "I need to make an appointment for pet grooming on {ReservationDate}"
  }

  sample_utterance {
    utterance = "I want to book a pet grooming appointment for {AnimalName} on {ReservationDate} at {ReservationTime}"
  }

  confirmation_setting {
    prompt_specification {
      message_group {
        message {
          plain_text_message {
            value = "Ok, I will book an appointment for {AnimalName} on {ReservationDate} at {ReservationTime}. Does this sound good?"
          }
        }
      }
      max_retries = 3
    }

    declination_response {
      message_group {
        message {
          plain_text_message {
            value = "No worries, I will not book the appointment."
          }
        }
      }
    }
  }

  #   slot_priority {
  #     slot_id  = aws_lexv2models_slot.AnimalName.slot_id
  #     priority = 1
  #   }

  #   slot_priority {
  #     slot_id  = aws_lexv2models_slot.AnimalType.slot_id
  #     priority = 2
  #   }

  #   slot_priority {
  #     slot_id  = aws_lexv2models_slot.ReservationDate.slot_id
  #     priority = 3
  #   }

  #   slot_priority {
  #     slot_id  = aws_lexv2models_slot.ReservationTime.slot_id
  #     priority = 4
  #   }

  #   depends_on = [
  #     aws_lexv2models_slot.AnimalName,
  #     aws_lexv2models_slot.AnimalType,
  #     aws_lexv2models_slot.ReservationDate,
  #     aws_lexv2models_slot.ReservationTime
  #   ]

}

resource "aws_lexv2models_slot" "AnimalName" {
  bot_id       = aws_lexv2models_bot.AppointmentBot.id
  bot_version  = "DRAFT"
  intent_id    = aws_lexv2models_intent.Book.intent_id
  locale_id    = aws_lexv2models_bot_locale.locale.locale_id
  name         = "AnimalName"
  slot_type_id = "AMAZON.AlphaNumeric"

  value_elicitation_setting {
    slot_constraint = "Required"
    prompt_specification {
      max_retries = 3
      message_group {
        message {
          plain_text_message {
            value = "What is the name of your pet?"
          }
        }
      }
    }
  }
}

resource "aws_lexv2models_slot" "AnimalType" {
  bot_id       = aws_lexv2models_bot.AppointmentBot.id
  bot_version  = "DRAFT"
  intent_id    = aws_lexv2models_intent.Book.intent_id
  locale_id    = aws_lexv2models_bot_locale.locale.locale_id
  name         = "AnimalType"
  slot_type_id = "AMAZON.AlphaNumeric"


  value_elicitation_setting {
    slot_constraint = "Required"
    prompt_specification {
      max_retries = 3
      message_group {
        message {
          plain_text_message {
            value = "What type of animal are you booking for?"
          }
        }
      }
    }
  }
}

resource "aws_lexv2models_slot" "ReservationDate" {
  bot_id       = aws_lexv2models_bot.AppointmentBot.id
  bot_version  = "DRAFT"
  intent_id    = aws_lexv2models_intent.Book.intent_id
  locale_id    = aws_lexv2models_bot_locale.locale.locale_id
  name         = "ReservationDate"
  slot_type_id = "AMAZON.Date"


  value_elicitation_setting {
    slot_constraint = "Required"
    prompt_specification {
      max_retries = 3
      message_group {
        message {
          plain_text_message {
            value = "What date?"
          }
        }
      }
    }
  }
}

resource "aws_lexv2models_slot" "ReservationTime" {
  bot_id       = aws_lexv2models_bot.AppointmentBot.id
  bot_version  = "DRAFT"
  intent_id    = aws_lexv2models_intent.Book.intent_id
  locale_id    = aws_lexv2models_bot_locale.locale.locale_id
  name         = "ReservationTime"
  slot_type_id = "AMAZON.Time"


  value_elicitation_setting {
    slot_constraint = "Required"
    prompt_specification {
      max_retries = 3
      message_group {
        message {
          plain_text_message {
            value = "What time?"
          }
        }
      }
    }
  }
}

resource "aws_iam_role" "lexv2-role" {
  name = "lexv2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lexv2.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "LexV2RolePolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["polly:SynthesizeSpeech"]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  tags = {
    tag-key = "lexv2-iam-role"
  }
}

resource "aws_lexv2models_slot_type" "animal_type" {
  name        = "AnimalType"
  bot_id      = aws_lexv2models_bot.AppointmentBot.id
  locale_id   = aws_lexv2models_bot_locale.locale.locale_id
  bot_version = "DRAFT"

  value_selection_setting {
    resolution_strategy = "OriginalValue"
  }

  slot_type_values {
    sample_value {
      value = "dog"
    }
  }

  slot_type_values {
    sample_value {
      value = "cat"
    }
  }

  slot_type_values {
    sample_value {
      value = "bird"
    }
  }

  slot_type_values {
    sample_value {
      value = "fish"
    }
  }
}

output "intent_id" {
  value = aws_lexv2models_intent.Book.id
}