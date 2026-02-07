import React from 'react';
import styled from 'styled-components';

const Container = styled.div`
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
`;

const Header = styled.header`
  background: #282c34;
  color: white;
  padding: 20px;
  margin-bottom: 20px;
  border-radius: 8px;
`;

const Main = styled.main`
  min-height: 60vh;
`;

const Footer = styled.footer`
  margin-top: 40px;
  padding: 20px;
  text-align: center;
  color: #666;
  border-top: 1px solid #eee;
`;

interface LayoutProps {
  children: React.ReactNode;
}

export const Layout: React.FC<LayoutProps> = ({ children }) => {
  return (
    <Container>
      <Header>
        <h1>My Project</h1>
        <p>Full-Stack AWS Application</p>
      </Header>
      <Main>{children}</Main>
      <Footer>
        <p>© {new Date().getFullYear()} My Project. Built with Gatsby & AWS.</p>
      </Footer>
    </Container>
  );
};
