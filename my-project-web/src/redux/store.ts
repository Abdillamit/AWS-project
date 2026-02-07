import { createStore, applyMiddleware, combineReducers } from 'redux';
import { createEpicMiddleware } from 'redux-observable';
import { appReducer } from './reducers/app-reducer';
import { rootEpic } from './epics/root-epic';

// Combine reducers
const rootReducer = combineReducers({
  app: appReducer,
});

export type RootState = ReturnType<typeof rootReducer>;

// Create epic middleware
const epicMiddleware = createEpicMiddleware();

// Create store
export const store = createStore(
  rootReducer,
  applyMiddleware(epicMiddleware)
);

// Run root epic
epicMiddleware.run(rootEpic);
