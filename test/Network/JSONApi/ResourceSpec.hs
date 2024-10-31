module Network.JSONApi.ResourceSpec where

import qualified Data.Aeson as AE
import qualified Data.ByteString.Lazy.Char8 as BS
import Data.Maybe (isJust, fromJust)
import Data.Text (Text, pack)
import GHC.Generics (Generic)
import Network.JSONApi
import Network.URL (URL, importURL)
import TestHelpers (prettyEncode)
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec =
  describe "JSON serialization" $
    it "can be encoded and decoded from JSON" $ do
      let encodedJson = BS.unpack . prettyEncode $ toResource testObject
      let decodedJson = AE.decode (BS.pack encodedJson) :: Maybe (Resource TestObject)
      isJust decodedJson `shouldBe` True
      {- putStrLn encodedJson -}
      {- putStrLn $ show . fromJust $ decodedJson -}

data TestObject = TestObject
  { myId :: Int
  , myName :: Text
  , myAge :: Int
  , myFavoriteFood :: Text
  } deriving (Show, Generic)

instance AE.ToJSON TestObject
instance AE.FromJSON TestObject

instance ResourcefulEntity TestObject where
  resourceIdentifier = pack . show . myId
  resourceType _ = "TestObject"
  resourceLinks _ = Just myResourceLinks
  resourceMetaData _ = Just myResourceMetaData
  resourceRelationships _ = Just myRelationshipss

data PaginationMetaObject = PaginationMetaObject
  { currentPage :: Int
  , totalPages :: Int
  } deriving (Show, Generic)

instance AE.ToJSON PaginationMetaObject
instance AE.FromJSON PaginationMetaObject
instance MetaObject PaginationMetaObject where
  typeName _ = "pagination"

myRelationshipss :: Relationships
myRelationshipss =
  mkRelationships relationship <> mkRelationships otherRelationship

relationship :: Relationship
relationship =
  fromJust $ mkRelationship
    (Just $ Identifier "42" "FriendOfTestObject" Nothing)
    (Just myResourceLinks)

otherRelationship :: Relationship
otherRelationship =
  fromJust $ mkRelationship
    (Just $ Identifier "49" "CousinOfTestObject" Nothing)
    (Just myResourceLinks)

myResourceLinks :: Links
myResourceLinks =
  mkLinks [ ("self", toURL "/me")
          , ("related", toURL "/tacos/4")
          ]

myResourceMetaData :: Meta
myResourceMetaData = mkMeta (PaginationMetaObject 1 14)

toURL :: String -> URL
toURL = fromJust . importURL

testObject :: TestObject
testObject = TestObject 1 "Fred Armisen" 49 "Pizza"
