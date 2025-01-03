#[starknet::contract]
mod credit_score {
   
    use starknet::storage::{Map};
    use core::option::Option;
    use core::starknet::{get_caller_address, ContractAddress};
   
    use core::starknet::storage::{
    
        StorageMapReadAccess,
        StorageMapWriteAccess,
       
    };
    

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        CreditScoreUpdated: CreditScoreUpdated,
        PaymentAdded: PaymentAdded,

        ScoringWeightsUpdated: ScoringWeightsUpdated,
        ProofVerified: ProofVerified,
    }

    #[derive(Drop, starknet::Event)]
    pub struct CreditScoreUpdated {
        pub caller: ContractAddress,
        pub new_score: u128,
    }

    #[derive(Drop, starknet::Event)]
    pub struct PaymentAdded {
        pub caller: ContractAddress,
        pub payment_date: u128,
        pub due_date: u128,
        pub amount_paid: u128,
        pub amount_due: u128,
    }


    #[derive(Drop, starknet::Event)]
    pub struct ScoringWeightsUpdated {
        pub caller: ContractAddress,
        pub new_on_time_weight: u128,
        pub new_payment_ratio_weight: u128,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ProofVerified {
        pub caller: ContractAddress,
        pub is_valid: bool,
        pub error_message: Option<ByteArray>, 
    }

    #[storage]
    struct Storage {
        scores: Map<ContractAddress, u128>,
        total_payments: Map<ContractAddress, u128>,
        on_time_payments: Map<ContractAddress, u128>,
        scoring_weights: Map<ContractAddress, (u128, u128)>,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.scoring_weights.write(get_caller_address(), (70, 30));
    }

    pub struct PaymentHistory {
        pub amount_due: u128,
        pub amount_paid: u128,
        pub payment_date: u128,
        pub due_date: u128,
        pub caller: ContractAddress,
    }
    #[starknet::interface]
    pub trait PaymentHistoryCalculatorTrait<TContractState>{
        fn calculate_on_time_percent(ref self: TContractState, caller: ContractAddress) -> u128;
        fn add_payment(ref self: TContractState, payment_date: u128, due_date: u128, amount_due: u128, amount_paid: u128);
       
        fn calculate_credit_score(ref self: TContractState, on_time_percent: u128, payment_ratio: u128) -> u128;
        fn set_credit_score(ref self: TContractState, score: u128);
        fn update_scoring_weights(ref self: TContractState, new_on_time_weight: u128, new_payment_ratio_weight: u128);
    }
    #[abi(embed_v0)]
    impl PaymentHistoryImpl of PaymentHistoryCalculatorTrait<ContractState> {
      
        fn calculate_on_time_percent(ref self: ContractState, caller: ContractAddress) -> u128 {
            let total = self.total_payments.read(caller);
            let on_time = self.on_time_payments.read(caller);

            if total == 0 {
                return 0;
            }

            (on_time * 100)
        }

     
        fn add_payment(ref self: ContractState, payment_date: u128, due_date: u128, amount_due: u128, amount_paid: u128) {
            let caller = get_caller_address();

            let total = self.total_payments.read(caller) + 1;
            self.total_payments.write(caller, total);

            let on_time = self.on_time_payments.read(caller);
            if payment_date <= due_date {
                self.on_time_payments.write(caller, on_time + 1);
            }

            self.emit(PaymentAdded {
                caller,
                payment_date,
                due_date,
                amount_paid,
                amount_due,
            });
        }

        
        
        fn calculate_credit_score(ref self: ContractState, on_time_percent: u128, payment_ratio: u128) -> u128 {
            let (on_time_weight, payment_ratio_weight) = self.scoring_weights.read(get_caller_address());

            let weighted_score = (on_time_percent * on_time_weight
                + payment_ratio * payment_ratio_weight)
                / 100;

            if weighted_score > 100 {
                100
            } else {
                weighted_score
            }
        }

  
        fn set_credit_score(ref self: ContractState, score: u128) {
            let caller = get_caller_address(); 
            self.scores.write(caller, score);

            self.emit(CreditScoreUpdated {
                caller,
                new_score: score,
            });
        }

        fn update_scoring_weights(ref self: ContractState, new_on_time_weight: u128, new_payment_ratio_weight: u128) {
            self.scoring_weights.write(get_caller_address(), (new_on_time_weight, new_payment_ratio_weight));

            self.emit(ScoringWeightsUpdated {
                caller: get_caller_address(),
                new_on_time_weight,
                new_payment_ratio_weight,
            });
        }

      
    }
    }

   
