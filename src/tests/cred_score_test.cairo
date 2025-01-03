#[cfg(test)]
mod tests {
    use super::*;
    use starknet::core::types::{ContractAddress, FieldElement};
    use starknet::prelude::*;
    
    fn get_sample_contract_address() -> ContractAddress {
        ContractAddress::new(FieldElement::from(1234u64))
    }

    #[test]
    fn test_add_payment() {
        let contract_address = get_sample_contract_address();
        let mut contract_state = ContractState::new();

        let payment_date = 1_000_000_000u128;
        let due_date = 1_000_000_100u128;
        let amount_due = 100u128;
        let amount_paid = 100u128;

        contract_state.add_payment(payment_date, due_date, amount_due, amount_paid);

        let total_payments = contract_state.total_payments.read(contract_address);
        assert_eq!(total_payments, 1);

        let on_time_payments = contract_state.on_time_payments.read(contract_address);
        assert_eq!(on_time_payments, 1);
    }

    #[test]
    fn test_calculate_credit_score() {
        let contract_address = get_sample_contract_address();
        let mut contract_state = ContractState::new();

        contract_state.update_scoring_weights(70, 30);

        let on_time_percent = 80u128;
        let payment_ratio = 75u128;

        let credit_score = contract_state.calculate_credit_score(on_time_percent, payment_ratio);

        assert_eq!(credit_score, 77);
    }

    #[test]
    fn test_update_scoring_weights() {
        let contract_address = get_sample_contract_address();
        let mut contract_state = ContractState::new();

        contract_state.update_scoring_weights(70, 30);

        let (on_time_weight, payment_ratio_weight) = contract_state.scoring_weights.read(contract_address);
        assert_eq!(on_time_weight, 70);
        assert_eq!(payment_ratio_weight, 30);

        contract_state.update_scoring_weights(60, 40);

        let (on_time_weight, payment_ratio_weight) = contract_state.scoring_weights.read(contract_address);
        assert_eq!(on_time_weight, 60);
        assert_eq!(payment_ratio_weight, 40);
    }

    #[test]
    fn test_proof_verified_event() {
        let contract_address = get_sample_contract_address();
        let mut contract_state = ContractState::new();

        let is_valid = true;
        let error_message: Option<ByteArray> = None;

        contract_state.emit(ProofVerified {
            caller: contract_address,
            is_valid,
            error_message,
        });

        let events = contract_state.get_emitted_events();
        assert_eq!(events.len(), 1);

        let proof_verified_event = &events[0];
        match proof_verified_event {
            Event::ProofVerified(event) => {
                assert_eq!(event.is_valid, true);
                assert_eq!(event.error_message, None);
            },
            _ => panic!("Unexpected event type"),
        }
    }
}
