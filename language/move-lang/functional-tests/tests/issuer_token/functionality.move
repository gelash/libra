//! account: bob, 0Coin1


// happy path:
//! new-transaction
//! sender: bob
script {
    use 0x1::IssuerToken::{Self, DefaultToken, MoneyOrderToken};
    use 0x1::Offer;

    fun main(account: &signer) {

        let def_issuer_token = IssuerToken::mint_issuer_token<DefaultToken>(account,0,10000);
        let mo_issuer_token = IssuerToken::mint_issuer_token<MoneyOrderToken>(account,0,10000);
        assert(IssuerToken::value<DefaultToken>(&def_issuer_token) == 10000, 0);
        assert(IssuerToken::value<MoneyOrderToken>(&mo_issuer_token) == 10000, 0);

        let splitted_dit = IssuerToken::split_issuer_token<DefaultToken>(&mut def_issuer_token, 5000);
        let splitted_moit = IssuerToken::split_issuer_token<MoneyOrderToken>(&mut mo_issuer_token, 5000);
        assert(IssuerToken::value<DefaultToken>(&def_issuer_token) == 5000 , 0);
        assert(IssuerToken::value<DefaultToken>(&splitted_dit) == 5000 , 1);
        assert(IssuerToken::value<MoneyOrderToken>(&mo_issuer_token) == 5000 , 2);
        assert(IssuerToken::value<MoneyOrderToken>(&splitted_moit) == 5000 , 3);

        IssuerToken::merge_issuer_token<DefaultToken>(&mut def_issuer_token, splitted_dit);
        IssuerToken::merge_issuer_token<MoneyOrderToken>(&mut mo_issuer_token, splitted_moit);
        assert(IssuerToken::value<DefaultToken>(&def_issuer_token) == 10000, 7);
        assert(IssuerToken::value<MoneyOrderToken>(&mo_issuer_token) == 10000, 8);

        Offer::create(account, def_issuer_token, {{bob}});
        Offer::create(account, mo_issuer_token, {{bob}});
    }
}
// check: EXECUTED



// invalid merge - different band id: (TODO: add test for different addresses, not sure how to do so now)
//! new-transaction
//! sender: bob
script {
    use 0x1::IssuerToken::{Self, DefaultToken};
    use 0x1::Offer;

    fun main(account: &signer) {
        let it1 = IssuerToken::mint_issuer_token<DefaultToken>(account,0,10000);
        let it2 = IssuerToken::mint_issuer_token<DefaultToken>(account,1,10000);
        IssuerToken::merge_issuer_token<DefaultToken>(&mut it1, it2);
        Offer::create(account, it1, {{bob}});
    }
}
// check: "Keep(ABORTED { code: 519"



// invalid split:
//! new-transaction
//! sender: bob
script {
    use 0x1::IssuerToken::{Self, DefaultToken};
    use 0x1::Offer;

    fun main(account: &signer) {
        let it1 = IssuerToken::mint_issuer_token<DefaultToken>(account,0,10000);
        let it2 = IssuerToken::split_issuer_token<DefaultToken>(&mut it1, 20000);
        Offer::create(account, it1, {{bob}});
        Offer::create(account, it2, {{bob}});
    }
}
// check: "Keep(ABORTED { code: 8"
