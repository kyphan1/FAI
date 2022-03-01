address 0x4FFCC98F43ce74668264a0CF6Eebe42b {
    module Treasury {

        use 0x1::Token;
        use 0x1::Signer;
        use 0x4FFCC98F43ce74668264a0CF6Eebe42b::Admin;
        use 0x4FFCC98F43ce74668264a0CF6Eebe42b::Config;

        const INVALID_AMOUNT: u64 = 301;

        struct Vault<TokenType: store> has key, store {
            token: Token::Token<TokenType>
        }

        public fun initialize<TokenType: store> (account: &signer) {
            Admin::is_admin_address(Signer::address_of(account));
            move_to(account, Vault<TokenType> {
                token: Token::zero<TokenType>()
            })
        }

        public fun deposit<TokenType: store> (tokens: Token::Token<TokenType>) acquires Vault {
            Config::check_global_switch();
            let admin_address = Admin::admin_address();
            let vault = borrow_global_mut<Vault<TokenType>>(admin_address);
            Token::deposit<TokenType>(&mut vault.token, tokens);
        }

        public fun withdraw<TokenType: store> (account: &signer, amount: u128): Token::Token<TokenType> acquires Vault {
            Config::check_global_switch();
            let vault = borrow_global_mut<Vault<TokenType>>(Signer::address_of(account));
            let reserve_amount = Token::value(&vault.token);
            assert(reserve_amount >= amount, INVALID_AMOUNT);
            Token::withdraw<TokenType>(&mut vault.token, amount)
        }

        public fun treasury_balance<TokenType: store>(): u128 acquires Vault {
            let admin_address = Admin::admin_address();
            let vault = borrow_global<Vault<TokenType>>(admin_address);
            Token::value<TokenType>(&vault.token)
        }
    }
}
