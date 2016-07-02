module Network.ErrorSpec where

import qualified Data.Aeson as AE
import qualified Data.ByteString.Lazy.Char8 as BS
import Data.Default (def)
import Data.Maybe
import Network.Error
import Prelude hiding (id)
import TestHelpers (prettyEncode)
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec =
  describe "Defaults" $ do
    it "Provide defaults" $
      let expectedDefault = Error
            { id     = Nothing
            , links  = Nothing
            , status = Nothing
            , code   = Nothing
            , title  = Nothing
            , detail = Nothing
            , meta   = Nothing
            }
      in (def::Error Int) `shouldBe` expectedDefault

    it "provides ToJSON/FromJSON instances" $ do
      let testError = (def::Error Int)
      let encJson = BS.unpack . prettyEncode $ testError
      let decJson = AE.decode (BS.pack encJson) :: Maybe (Error Int)
      isJust decJson `shouldBe` True
      {- putStrLn encJson -}
      {- putStrLn $ show . fromJust $ decJson -}