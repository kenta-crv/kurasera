# jwork側のセッションCookieを上書きしないよう、固有のキーを設定します。
Rails.application.config.session_store :cookie_store, key: '_okwork_session'