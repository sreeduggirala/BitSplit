import Head from 'next/head';
import NavBar from '../components/NavBar';

const Home = () => {
  return (
    <div>
      <Head>
        <title>BitWise</title>
        <meta
          content="SplitWise, but with Crypto."
          name="description"
        />
        <link href="/favicon.ico" rel="icon" />
      </Head>

      <div className=' h-screen w-screen bg-blue-200 flex justify-center items-start'>
        <NavBar />
      </div>
    </div>
  );
};

export default Home;
